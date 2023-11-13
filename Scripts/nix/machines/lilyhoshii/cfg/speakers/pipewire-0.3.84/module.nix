{ ... }:

{
	imports = [
		<nixpkgs_staging/nixos/modules/services/desktops/pipewire/pipewire.nix>
	];
	disabledModules = [
		"services/desktops/pipewire/pipewire.nix"
	];
}
