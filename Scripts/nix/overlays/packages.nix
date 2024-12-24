{
  pkgs,
  inputs,
}:

let
  callPackage = pkgs.lib.callPackageWith (
    pkgs
    // {
      _self = inputs.self;
      _inputs = inputs;
    }
  );
in

{
  blobmoji = callPackage ./packages/blobmoji { };
  bonito = callPackage ./packages/bonito { };
  caddy = callPackage ./packages/caddy { };
  caddyv1 = callPackage ./packages/caddyv1 { };
  catnip-gtk = callPackage ./packages/catnip-gtk { };
  dissent = callPackage ./packages/dissent.nix { };
  drone-ci = callPackage ./packages/drone-ci { };
  ghproxy = callPackage ./packages/ghproxy { };
  gotab = callPackage ./packages/gotab.nix { };
  inconsolata = callPackage ./packages/inconsolata.nix { };
  intiface-cli = callPackage ./packages/intiface-cli { };
  nix-search = callPackage ./packages/nix-search.nix { };
  openmoji = callPackage ./packages/openmoji { };
  osu-wine = callPackage ./packages/osu-wine { };
  osu-wineprefix = callPackage ./packages/osu-wineprefix { };
  oxfs = callPackage ./packages/oxfs.nix { };
  passwordsafe = callPackage ./packages/gnome-passwordsafe { };
  perf_data_converter = callPackage ./packages/perf_data_converter.nix { };
  srain = callPackage ./packages/srain { };
  tagtool = callPackage ./packages/tagtool.nix { };
  transmission-web = callPackage ./packages/transmission-web { };
  vkmark = callPackage ./packages/vkmark { };
  xcaddy = callPackage ./packages/xcaddy { };
  ymuse = callPackage ./packages/ymuse { };
}
