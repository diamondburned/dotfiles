let nixosPkgs = import <nixos> {};
	lib = nixosPkgs.lib;

	waylandOverlays = import (nixosPkgs.fetchFromGitHub {
		owner  = "colemickens";
		repo   = "nixpkgs-wayland";
		rev    = "b9db16d610dc1ce6087cf4070e6394a11d0115fc";
		sha256 = "1l49m9ws72gkvx579y178h5zy4aydv62dz3lqcn382rgif4rzn9w";
	});

in import <nixos> {
	overlays = [ waylandOverlays ];
}
