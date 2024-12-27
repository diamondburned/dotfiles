{
  pkgs,
  inputs,
}:

let
  callPackage = pkgs.lib.callPackageWith (
    pkgs
    // {
      _inputs = inputs;
    }
  );
in

{
  blobmoji = callPackage ./blobmoji { };
  bonito = callPackage ./bonito { };
  caddy = callPackage ./caddy { };
  caddyv1 = callPackage ./caddyv1 { };
  catnip-gtk = callPackage ./catnip-gtk { };
  dissent = callPackage ./dissent.nix { };
  drone-ci = callPackage ./drone-ci { };
  ghproxy = callPackage ./ghproxy { };
  gotab = callPackage ./gotab.nix { };
  inconsolata = callPackage ./inconsolata.nix { };
  intiface-cli = callPackage ./intiface-cli { };
  lineprompt = callPackage ./lineprompt { };
  nix-search = callPackage ./nix-search.nix { };
  openmoji = callPackage ./openmoji { };
  oxfs = callPackage ./oxfs.nix { };
  passwordsafe = callPackage ./gnome-passwordsafe { };
  perf_data_converter = callPackage ./perf_data_converter.nix { };
  srain = callPackage ./srain { };
  tagtool = callPackage ./tagtool.nix { };
  transmission-web = callPackage ./transmission-web { };
  vkmark = callPackage ./vkmark { };
  xcaddy = callPackage ./xcaddy { };
  ymuse = callPackage ./ymuse { };
}
