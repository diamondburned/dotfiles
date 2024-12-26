{ buildGoModule, lib }:

buildGoModule {
	name = "drone-ci";
	version = "v1.9.1";

	src = builtins.fetchGit {
		url = "https://github.com/drone/drone.git";
		ref = "v1.9.1";
	};

	vendorHash = "0h1kq54gshjmz1wlxrjfbhfs35nq64jcn25w3h8y12hp2k5jqgkw";
}
