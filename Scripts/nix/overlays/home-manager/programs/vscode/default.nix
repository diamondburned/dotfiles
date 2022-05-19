{ config, lib, pkgs, ... }:

with lib;

let cfg = config.programs.vscode-css;

    # Helper function to encode md5sum in base64.
    md5b64 = builtins.readFile ./md5b64.sh;

    appPath  = "lib/vscode/resources/app";
    htmlFile = "vs/code/electron-browser/workbench/workbench.html";
    prodPath = "${appPath}/product.json";
    htmlPath = "${appPath}/out/${htmlFile}";

	# cssPath type []string
	htmlPatch = cssPaths:
		let css = flip concatMapStrings cssPaths (css:
			"\t\t<link rel=\"stylesheet\" type=\"text/css\" href=\"${css}\">\n"
		);
		in ''
            path="$out/${htmlPath}" # absolute path to workbench.html
			prod="$out/${prodPath}" # absolute path to product.json

			# Read the HTML file
			html=$(< $path)

			# Form HTML headers
			printf -v headers "\n%s\n" '${css}' 

			# Write the HTML file
			echo "''${html/<head>/<head>$headers}" > $path

            # Function to encode md5sum in base64 digest
            ${md5b64}

            # Obtain the checksum of the modified file
            b64sum=$(md5b64 $path)

            # Store the original product.json before changing
            mv $prod $prod.bak

            # Replace the original checksum in product.json
			${pkgs.jq}/bin/jq --arg h $b64sum '.checksums."${htmlFile}" = $h' $prod.bak > $prod
		'';

in {
	options = {
		programs.vscode-css = {
			files = mkOption {
				type = types.listOf types.path;
				default = [];
				description = ''
					A list of custom CSS files to import.
				'';
			};

			package = mkOption {
				type = types.package;
				default = pkgs.vscode;
			};
		};
	};

	config = mkIf (cfg.files != []) {
		programs.vscode.package = cfg.package.overrideAttrs(old: {
		    postFixup = (old.postPatch or "") + (htmlPatch cfg.files);
		});
		# cfg.package = if (cfg.customCSS == []) then cfg.package else (
		# );
	};
}
