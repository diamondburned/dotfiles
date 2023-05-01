self: super: {
	# Linux xanmod with LTO.
	linux_xanmod-lto = super.callPackage ./xanmod-lto.nix {
		linux_xanmod = super.linuxKernel.kernels.linux_xanmod;
	};
	linux_xanmod_latest-lto = super.callPackage ./xanmod-lto.nix {
		linux_xanmod = super.linuxKernel.kernels.linux_xanmod_latest;
	};
}
