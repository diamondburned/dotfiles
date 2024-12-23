{
  config,
  lib,
  pkgs,
  ...
}:

let
  steam = pkgs.steam.override (
    {
      extraLibraries ? pkgs': [ ],
      ...
    }:
    {
      # Workaround for TF2.
      # See https://github.com/ValveSoftware/Source-1-Games/issues/5043#issuecomment-1822019817.
      extraLibraries =
        pkgs':
        (extraLibraries pkgs')
        ++ (with pkgs'; [
          gperftools
          openssl
          openssl_1_1
        ]);
    }
  );
in

{
  programs.steam = {
    enable = true;
    package = steam;
    gamescopeSession.enable = true;
    remotePlay.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
  };

  environment.systemPackages = [
    steam
    steam.run
  ];

  nixpkgs.config.permittedInsecurePackages = [
    "openssl-1.1.1w"
  ];
}
