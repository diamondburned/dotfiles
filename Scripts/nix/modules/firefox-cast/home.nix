{ pkgs, ... }:

{
  home.packages = with pkgs; [
    fx-cast-bridge
  ];

  programs.firefox.nativeMessagingHosts = with pkgs; [
    fx-cast-bridge
  ];
}
