{ buildGoModule, lib }:

buildGoModule {
	name = "ghproxy";
	version = "tunnel-1";

	src = builtins.fetchGit {
		url = "git@github.com:diamondburned/ghproxy.git";
		rev = "3a5600699c164a85d3112208330b2dc6528fce59";
		ref = "tunnel";
	};

	vendorHash = "066fisgpicxv8dx9s2n6kvrrlfg5whvckgqi7bgmw3vh1jsy0qv9";
}
