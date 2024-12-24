{
  pkgs,
  inputs,
}:

let
  inherit (inputs) self;

  sources = import "${self}/nix/sources.nix" {
    inherit (pkgs) system;
  };

  combinedInputs =
    { }
    # Mark Niv inputs with a _type:
    // (pkgs.lib.mapAttrs (src: src // { _type = "niv"; }) sources)
    # Flake inputs are already marked with a _type:
    // (inputs);

  callPackage = pkgs.callPackageWith (
    pkgs
    // {
      inputs = combinedInputs;
    }
  );
in

{
  transmission-web = callPackage ./packages/transmission-web { };
  ytmdesktop = callPackage ./packages/ytmdesktop.nix { };
  tagtool = callPackage ./packages/tagtool.nix { };
  ymuse = callPackage ./packages/ymuse { };
  srain = callPackage ./packages/srain { };
  caddy = callPackage ./packages/caddy { };
  xcaddy = callPackage ./packages/xcaddy { };
  caddyv1 = callPackage ./packages/caddyv1 { };
  vkmark = callPackage ./packages/vkmark { };
  bonito = callPackage ./packages/bonito { };
  ghproxy = callPackage ./packages/ghproxy { };
  dissent = callPackage ./packages/dissent.nix { };
  openmoji = callPackage ./packages/openmoji { };
  blobmoji = callPackage ./packages/blobmoji { };
  drone-ci = callPackage ./packages/drone-ci { };
  gappdash = callPackage ./packages/gappdash { };
  gotktrix = callPackage ./packages/gotktrix.nix { };
  osu-wine = callPackage ./packages/osu-wine { };
  osu-wineprefix = callPackage ./packages/osu-wineprefix { };
  gotab = callPackage ./packages/gotab.nix { };
  oxfs = callPackage ./packages/oxfs.nix { };
  nix-search = callPackage ./packages/nix-search.nix { };
  inconsolata = callPackage ./packages/inconsolata.nix { };
  intiface-cli = callPackage ./packages/intiface-cli { };
  catnip-gtk = callPackage ./packages/catnip-gtk { };
  passwordsafe = callPackage ./packages/gnome-passwordsafe { };
  google-chrome-ozone = callPackage ./packages/google-chrome-ozone { };
  lightdm-elephant-greeter = callPackage ./packages/lightdm-elephant-greeter;
  rhythmbox-alternative-toolbar = callPackage ./packages/rhythmbox-alternative-toolbar { };
  perf_data_converter = callPackage ./packages/perf_data_converter.nix { };
  typescript-transpile-only = callPackage ./packages/typescript-transpile-only { };
}
