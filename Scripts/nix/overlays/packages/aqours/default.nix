{ pkgs, lib }:

let src = pkgs.fetchFromGitHub {
		owner  = "diamondburned";
		repo   = "aqours";
		rev    = "067a45c";
		sha256 = "18zylsapp7sx7kkblmgg569spb6kzgvzjrmwg5j7vgff27q8cscp";
	};

	shell = import "${src}/shell.nix" {
		inherit pkgs;
	};

in pkgs.buildGo117Module {
	name = "aqours";
	version = "d3e4f3b";

	inherit src;

	buildInputs = shell.buildInputs;

	nativeBuildInputs = with pkgs; [
		pkg-config
		glib
		wrapGAppsHook
	];

	vendorSha256 = "1xxxcalamfcyi6dhqyvr77a7qf5bmgjgmhwvzc63yisir1m9i8dn";
}
