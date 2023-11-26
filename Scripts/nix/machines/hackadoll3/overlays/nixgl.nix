self: super: {
	nixGL = (import <nixGL> { pkgs = super; }).nixGLIntel;
	nixGLWrap =
		{ pkg, bin ? pkg.meta.mainProgram }:

		super.runCommandLocal "${pkg.pname}-nixgl" {
			buildInputs = [ pkg self.nixGL ];
			nativeBuildInputs = with super; [ makeWrapper ];
		} ''
			set -x
			mkdir $out
			for dir in ${pkg}/*; do
				[[ $dir == */bin ]] && continue
				ln -s $dir $out/
			done
			mkdir $out/bin
			for bin in ${pkg}/bin/*; do
				dst=$out/bin/$(basename "$bin")
				echo "#!${super.runtimeShell}" >> $dst
				echo "exec ${self.nixGL}/bin/nixGLIntel $bin "'$@' >> $dst
			done
		'';
	nixGLWrapBin = pkg: self.nixGLWrap { inherit pkg; };
}
