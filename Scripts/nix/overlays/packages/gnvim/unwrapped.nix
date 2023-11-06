{ lib, rustPlatform, fetchFromGitHub, pkg-config, glib, gtk4 }:

rustPlatform.buildRustPackage rec {
  pname = "gnvim-unwrapped";
  version = builtins.substring 0 7 "${src.rev}";

  src = fetchFromGitHub {
		owner = "vhakulinen";
		repo = "gnvim";
		rev = "b567f741da22cf211088d7748494d849e13f6298";
		sha256 = "sha256-oDNMTzfSWmBKafv01oL6PYAgEst+kGkqM9Rr/DG+vYw=";
	};

  # cargoLock.lockFile = ./Cargo.lock;
	cargoLock.lockFile = builtins.toPath "${src}/Cargo.lock";

  nativeBuildInputs = [
    pkg-config
    # for the `glib-compile-resources` command
    glib
  ];
  buildInputs = [ glib gtk4 ];

  # The default build script tries to get the version through Git, so we
  # replace it
  postPatch = ''
    # Install the binary ourselves, since the Makefile doesn't have the path
    # containing the target architecture
    sed -e "/target\/release/d" -i Makefile
  '';

  postInstall = ''
		ls $out
		ls $out/bin
    make install PREFIX="${placeholder "out"}"
  '';

  # GTK fails to initialize
  doCheck = false;

  meta = with lib; {
    description = "GUI for neovim, without any web bloat";
    homepage = "https://github.com/vhakulinen/gnvim";
    license = licenses.mit;
    maintainers = with maintainers; [ minijackson ];
  };
}
