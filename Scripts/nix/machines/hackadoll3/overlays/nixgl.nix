self: super: {
	nixGL = (import <nixGL> { pkgs = super; }).nixGLIntel;
	nixGLWrap =
		{ pkg, bin ? pkg.meta.mainProgram }:

		super.runCommandLocal "${pkg.pname}-nixgl" {
			buildInputs = [ pkg self.nixGL ];
			nativeBuildInputs = with super; [ makeWrapper ];
		} ''
			mkdir -p $out
			for dir in ${pkg}/!(bin); do
				ln -s $dir $out
			done
			for bin in ${pkg}/bin/*; do
				dst=$out/bin/$(basename "$bin")
				echo "#!${super.runtimeShell}" >> $dst
				echo "exec ${self.nixGL}/bin/nixGLIntel $bin \"\$@\"" >> $dst
			done
		'';
		super.symlinkJoin {
			name = "${pkg.pname}-nixgl";
			paths = [
				(super.writeShellScriptBin "${bin}" ''
					exec ${self.nixGL}/bin/nixGLIntel ${pkg}/bin/${bin} "$@"
				'')
				(pkg)
			];
		}
;
	nixGLWrapBin = pkg: self.nixGLWrap { inherit pkg; };
}
