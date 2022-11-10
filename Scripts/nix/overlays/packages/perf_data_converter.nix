{ pkgs }:

pkgs.buildBazelPackage rec {
	pname = "perf_data_converter";
	version = "gd134bfd";

	src = pkgs.fetchFromGitHub {
		owner = "google";
		repo  = "perf_data_converter";
		rev   = "d134bfd";
		hash  = "sha256:151kamwkjkys1b5byfs94j38p7qciak1wgi9gqgk96dzk0k2gbgm";
	};

	bazelTarget = "src:perf_to_profile";

	buildInputs = with pkgs; [
		elfutils
		libelf
		libcap
	];

	nativeBuildInputs = with pkgs; [
		go
	];

	buildAttrs = {
	    installPhase = ''
			(
				cd bazel-out/k8-fastbuild/bin/src
				for f in perf_*; {
					[[ ! -d "$f" && -x "$f" ]] && install -Dm755 "$f" "$out/bin/$f"
				}
			)
	    '';
	};

	NIX_CFLAGS_COMPILE = "-Wno-error";

	fetchAttrs = {
		sha256 = "0jdc6wwr6y168x5ykxw96602yqjgw4rzilx5bgx3pkvli995hq77";
	};
}
