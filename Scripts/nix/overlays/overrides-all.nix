self: super:

let
	lib = self.lib;
in

{
	gnvim = super.callPackage ./packages/gnvim { };

  autoPatchelf =
		{ pkg, buildInputs ? [] }:

		super.stdenv.mkDerivation {
			name = "${pkg.name}-patched";

			phases = [ "installPhase" "fixupPhase" ];
			buildInputs = buildInputs;
			nativeBuildInputs = with super; [ autoPatchelfHook ];

			installPhase = ''
				mkdir -p $out
				cp -ra --no-preserve=mode ${pkg}/* $out
			'';
		};

	# autoPatchelf = pkg: super.runCommandLocal "${pkg.name}-patched" {
	# 	nativeBuildInputs = with super; [ autoPatchelfHook ];
	# } ''
	# 	mkdir -p $out
	# 	cp -r ${pkg}/* $out
	# '';
}
