{ rustPlatform, fetchFromGitHub, pkg-config, gobject-introspection, gtk4, glib, cairo, pango,
  gdk-pixbuf, atk, vte, wrapGAppsHook4, lib }:
	
rustPlatform.buildRustPackage rec {
	name = "neovim-gtk-unstable-${version}";
	version = "1.0.4";

	src = fetchFromGitHub {
		owner  = "Lyude";
		repo   = "neovim-gtk";
		rev	   = "v${version}";
		sha256 = "1wp3rp416k736gqr3dws43k3l9193ag2jppibvdhsfrhjvpdlywa";
	};

	cargoSha256 = "1akx4ygzpccpsiv7xh43adddcnwgfzqg16aj4m01w379ln0qszr4";

	nativeBuildInputs = [
		pkg-config
		wrapGAppsHook4
		gobject-introspection
	];

	buildInputs = [
	    glib
	    cairo
	    pango
	    gdk-pixbuf
	    atk
	    gtk4
		vte
	];

	postInstall = ''
			mkdir -p $out/share/nvim-gtk/
			cp -r runtime $out/share/nvim-gtk/
			mkdir -p $out/share/applications/
			sed -e "s|Exec=nvim-gtk|Exec=$out/bin/nvim-gtk|" \
			desktop/org.daa.NeovimGtk.desktop \
					>$out/share/applications/org.daa.NeovimGtk.desktop
			mkdir -p $out/share/icons/hicolor/128x128/apps/
		cp desktop/org.daa.NeovimGtk_128.png $out/share/icons/hicolor/128x128/apps/org.daa.NeovimGtk.png
		mkdir -p $out/share/icons/hicolor/48x48/apps/
		cp desktop/org.daa.NeovimGtk_48.png $out/share/icons/hicolor/48x48/apps/org.daa.NeovimGtk.png
		mkdir -p $out/share/icons/hicolor/scalable/apps/
		cp desktop/org.daa.NeovimGtk.svg $out/share/icons/hicolor/scalable/apps/
		mkdir -p $out/share/icons/hicolor/symbolic/apps/
		cp desktop/org.daa.NeovimGtk-symbolic.svg $out/share/icons/hicolor/symbolic/apps/
	'';

	meta = with lib; {
		description = "GTK+ UI for Neovim";
		homepage = https://github.com/Lyude/neovim-gtk;
		license = licenses.gpl3;
		platforms = platforms.linux;
	};
}

