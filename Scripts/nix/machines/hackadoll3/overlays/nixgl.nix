self: super: {
	nixGL = (import <nixGL> { pkgs = super; }).nixGLIntel;
}
