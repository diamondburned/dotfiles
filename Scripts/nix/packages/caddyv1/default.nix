{ stdenv, lib,
  runCommand, writeText,
  buildGoModule, go, modSha256 ? "",
  plugins ? [] }:

with lib;

let imports = flip concatMapStrings plugins (pkg: "\t\t\t_ \"${pkg}\"\n");
	main    = writeText "caddy-main.go" ''
		package main
	
		import (
			"github.com/caddyserver/caddy/caddy/caddymain"
${imports}
		)

		func main() {
			caddymain.EnableTelemetry = false
			caddymain.Run()
		}
	'';

	version = "v1.0.5";

	vendorHash = (if (modSha256 != "") then modSha256 else
		"09ccjcdybjcc0nl9gcd91f4kf61h8ydcc7lwp9m0yzmgv6w15gpr"
	);

in buildGoModule rec {
	name = "caddy";
	inherit version vendorHash;

	overrideModAttrs = (_: {
		postInstall = "cp go.sum go.mod $out/ && ls $out/";
	});

	postConfigure = ''
		cp vendor/go.sum ./
		cp vendor/go.mod ./
	'';

	src = runCommand "caddy-src" {
		buildInputs = [ go ];
	} ''
		export HOME="$TMPDIR"
		export GOPATH="$TMPDIR"

		mkdir $out && cd $out

		go mod init caddy

cat <<'EOF' >> go.mod

require (
	github.com/caddyserver/caddy ${version}
)

EOF

		cp ${main} main.go
	'';


	meta = with pkgs.lib; {
		homepage = https://caddyserver.com;
		description = "Fast, cross-platform HTTP/2 web server with automatic HTTPS";
		license = licenses.asl20;
	};
}
