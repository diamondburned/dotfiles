{ lib, fetchFromGitHub, rustPlatform, gnome }:

rustPlatform.buildRustPackage rec {
	name = "neovim-gtk-${version}";
	version = "0.2.0";

	src = fetchFromGitHub {
		owner  = "daa84";
		repo   = "neovim-gtk";
		rev    = "v${version}";
		sha256 = "0idn0j41h3bvyhcq2k0ywwnbr9rg9ci0knphbf7h7p5fd4zrfb30";
	};

	buildInputs = with gnome; [ gtk glib ];

	checkPhase = "";
	cargoSha256 = "1p77x1g13pzkdc6mx9lhzpj5ds541vq1qlj9hqba6nf9r7vqr0rk";

	meta = {
		description = "Neovim Gtk frontend in Rust.";
	};
}
