{
	stdenv, fetchgit, makeWrapper, wrapGAppsHook,
	libhandy, libpwquality, python3, gtk3, glib,
	meson, ninja, pkg-config, cmake, gobject-introspection,
}:

python3.pkgs.buildPythonApplication rec {
	pname = "passwordsafe";
	version = "3.32.1";

	format = "other";

	name = "${pname}-${version}";

	src = fetchgit {
		url = "https://gitlab.gnome.org/diamondburned/PasswordSafe.git";
		rev = "5ab72a2a48f45c41d7a1cca2dab9634ea36198f0";
		sha256 = "1i458p51wby00sjjfv9838b3hmgwzlbyvwqkxhzlsj7kzxr57c80";
	};

	buildInputs = [
		gtk3
		glib
		gobject-introspection
	];

	propagatedBuildInputs = [
		libhandy
		(libpwquality.override {
			python = python3;
		})

	] ++ (with python3.pkgs; [
		pykeepass
		pygobject3
		libkeepass
	]);

	nativeBuildInputs = buildInputs ++ [
		wrapGAppsHook
		meson
		ninja
		pkg-config
		cmake
	];

	meta = with pkgs.lib; {
		description = "Password manager for GNOME which makes use of the KeePass v.4 format";
		homepage = https://gitlab.gnome.org/World/PasswordSafe;
		license = licenses.gpl3;
		platforms = platforms.linux;
	};
}
