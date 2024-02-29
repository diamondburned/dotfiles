self: super:

let
	lib = self.lib;
in

{
	gnvim = super.callPackage ./packages/gnvim { };

	# autoPatchelf = pkg: super.runCommandLocal "${pkg.name}-patched" {
	# 	nativeBuildInputs = with super; [ autoPatchelfHook ];
	# } ''
	# 	mkdir -p $out
	# 	cp -r ${pkg}/* $out
	# '';
}
