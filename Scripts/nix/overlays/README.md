## Usage

```nix
{ config, pkgs, ... }:

let diamond-overlay = builtins.fetchGit {
	url = "https://git.sr.ht/~diamondburned/nix-overlays";
	ref = "master"; # use commit rev if needed
}

{
	imports = [ "${diamond-overlay}" ];

	environment.systemPackages = with pkgs; [
		drone-ci
	];

	services.drone-ci = {
		enable = true;
		config = {}; # ...
	};
}
```
