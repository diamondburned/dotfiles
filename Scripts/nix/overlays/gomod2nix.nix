final: prev:

let
	src = <gomod2nix>;
	callPackage = prev.callPackage;
in

{
  inherit (callPackage "${src}/builder" { }) buildGoApplication mkGoEnv;
	gomod2nix = (callPackage "${src}" { }).overrideAttrs (old: {
		# Fix unpack error.
		unpackCmd = "mkdir gomod2nix && cp -r $curSrc/* gomod2nix";
	});
}
