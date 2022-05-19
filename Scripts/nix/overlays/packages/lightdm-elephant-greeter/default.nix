{ pkgs, python3, lib, stdenv }:

let pyEnv = python3.withPackages (pkgs: with pkgs; [ pygobject3 ]);

in stdenv.mkDerivation {
	passthru.xgreeters = linkFarm "lightdm-elephant-greeter-xgreeters" [{
		path = "${}";
	}];
}
