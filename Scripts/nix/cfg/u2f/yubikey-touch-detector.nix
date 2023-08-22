{ lib, libnotify, gnupg, makeWrapper, buildGoModule, fetchFromGitHub, fetchurl, pkg-config, iconColor ? "#84bd00" }:

buildGoModule rec {
  pname = "yubikey-touch-detector";
  version = "1.10.1";

  src = fetchFromGitHub {
		owner = "diamondburned";
		repo = "yubikey-touch-detector";
		rev = "3776780";
		sha256 = "sha256-sTSNRdvXyrOvaPwpFFG9daRq2IhSQfsJc+6l2s1rFR4=";
	};
  vendorHash = "sha256-SwgaZvqH6g6Cr+K1BzMpkz8yvwB01ie6PkhJSCYMcXY=";

  iconSrc = fetchurl {
    url = "https://github.com/Yubico/yubioath-flutter/raw/yubioath-desktop-5.0.0/images/touch.svg";
    hash = "sha256-+jC9RKjl1uMBaNqLX5WXN+E4CuOcIEx5IGXWxgxzA/k=";
  };

  nativeBuildInputs = [ pkg-config makeWrapper ];

  buildInputs = [ libnotify ];

  postPatch = ''
    cp ${iconSrc} yubikey-touch-detector.svg
    substituteInPlace yubikey-touch-detector.svg \
      --replace '#284c61' ${lib.escapeShellArg iconColor}

    substituteInPlace notifier/libnotify.go \
      --replace \
        'AppIcon: "yubikey-touch-detector"' \
        "AppIcon: \"$out/share/icons/yubikey-touch-detector.svg\""
  '';

  postInstall = ''
    install -Dm444 -t $out/share/doc/${pname} *.md

    install -Dm444 -t $out/share/icons yubikey-touch-detector.svg

    install -Dm444 -t $out/lib/systemd/user *.{service,socket}

    substituteInPlace $out/lib/systemd/user/*.service \
			--replace /usr/bin/yubikey-touch-detector "$out/bin/yubikey-touch-detector --libnotify" \
			--replace EnvironmentFile= $'Restart=always\nEnvironmentFile='

		wrapProgram $out/bin/yubikey-touch-detector \
			--prefix PATH : "${lib.makeBinPath [ gnupg ]}"
  '';

  meta = with lib; {
    description = "A tool to detect when your YubiKey is waiting for a touch (to send notification or display a visual indicator on the screen).";
    homepage = "https://github.com/maximbaz/yubikey-touch-detector";
    maintainers = with maintainers; [ sumnerevans ];
    license = with licenses; [ bsd2 isc ];
    platforms = platforms.linux;
  };
}
