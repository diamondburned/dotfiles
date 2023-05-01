{
	pkgs,
	stdenv,
	lib,
	linux_xanmod,
	...
} @ args:
# https://sourcegraph.com/github.com/xddxdd/nur-packages/-/blob/pkgs/lantian-customized/linux-xanmod-lantian/default.nix.
# https://sourcegraph.com/github.com/cpcloud/nix-config/-/blob/nix/overlays/linux-lto.nix
# https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/os-specific/linux/kernel/linux-xanmod.nix
let
	# https://github.com/NixOS/nixpkgs/pull/129806
	# https://github.com/lovesegfault/nix-config/blob/master/nix/overlays/linux-lto.nix
	stdenvLLVM = let
		noBintools = {
			bootBintools = null;
			bootBintoolsNoLibc = null;
		};
		hostLLVM = pkgs.pkgsBuildHost.llvmPackages_latest.override noBintools;
		buildLLVM = pkgs.pkgsBuildBuild.llvmPackages_latest.override noBintools;

		mkLLVMPlatform = platform: platform // {
			linux-kernel = platform.linux-kernel // {
				makeFlags = (platform.linux-kernel.makeFlags or []) ++ [
					"LLVM=1"
					"LLVM_IAS=1"
					"CC=${buildLLVM.clangUseLLVM}/bin/clang"
					"LD=${buildLLVM.lld}/bin/ld.lld"
					"HOSTLD=${hostLLVM.lld}/bin/ld.lld"
					"AR=${buildLLVM.llvm}/bin/llvm-ar"
					"HOSTAR=${hostLLVM.llvm}/bin/llvm-ar"
					"NM=${buildLLVM.llvm}/bin/llvm-nm"
					"STRIP=${buildLLVM.llvm}/bin/llvm-strip"
					"OBJCOPY=${buildLLVM.llvm}/bin/llvm-objcopy"
					"OBJDUMP=${buildLLVM.llvm}/bin/llvm-objdump"
					"READELF=${buildLLVM.llvm}/bin/llvm-readelf"
					"HOSTCC=${hostLLVM.clangUseLLVM}/bin/clang"
					"HOSTCXX=${hostLLVM.clangUseLLVM}/bin/clang++"
				];
			};
		};

		stdenv' = pkgs.overrideCC hostLLVM.stdenv hostLLVM.clangUseLLVM;
	in
		stdenv'.override (old: {
			hostPlatform = mkLLVMPlatform old.hostPlatform;
			buildPlatform = mkLLVMPlatform old.buildPlatform;
			extraNativeBuildInputs = [hostLLVM.lld pkgs.patchelf];
		});

	kernel = x86_64-march: linux_xanmod.override {
		stdenv = stdenvLLVM;
		buildPackages = pkgs.pkgsBuildHost // { stdenv = stdenvLLVM; };

		argsOverride.structuredExtraConfig = with lib.kernel; structuredExtraConfig // {
				LOCALVERSION = freeform "-${x86_64-march}-lto";
				LTO_NONE = none;
				LTO_CLANG_FULL = yes;
				DEBUG_INFO = lib.mkForce no;

				GENERIC_CPU  = if x86_64-march == "v1" then yes else no;
				GENERIC_CPU2 = if x86_64-march == "v2" then yes else no;
				GENERIC_CPU3 = if x86_64-march == "v3" then yes else no;
				GENERIC_CPU4 = if x86_64-march == "v4" then yes else no;
		};
	};
in
	rec {
		x86_64-v1 = kernel "v1";
		x86_64-v2 = kernel "v2";
		x86_64-v3 = kernel "v3";
		x86_64-v4 = kernel "v4";

		generic = x86_64-v1;
	}
