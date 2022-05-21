{
	description = "A very basic flake";

	inputs = {
		# Nixpkgs inputs.
		nixpkgs.url = "github:NixOS/nixpkgs/1ffba9f2f68"; # nixos-unstable
		nixpkgs-21_11.url = "github:NixOS/nixpkgs/8b3398bc7587ebb79f93dfeea1b8c574d3c6dba1";

		# Overlay inputs.
		home-manager.url = "github:nix-community/home-manager";
		nix-wayland.url = "github:nix-community/nixpkgs-wayland";
		polymc.url = "github:PolyMC/PolyMC/develop";
	};

	outputs = inputs: {
		nixosConfigurations = {
			"hackadoll3" = inputs.nixpkgs.lib.nixosSystem {
				system = "x86_64-linux";
				modules = [ ./configuration.nix ];
				specialArgs = { inherit inputs; };
			};
		};
	};
}
