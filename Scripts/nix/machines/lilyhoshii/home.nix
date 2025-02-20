{
  config,
  lib,
  pkgs,
  self,
  ...
}:

{
  home-manager.backupFileExtension = "bak";

  home-manager.users.diamond = {
    imports = [
      self.homeModules.firefox
      self.homeModules.zellij
      self.homeModules.fonts
      self.homeModules.gnome
      self.homeModules.nvim
      self.homeModules.foot
      self.homeModules.git
      self.homeModules.gtk
      self.homeModules.nvim
      self.homeModules.gnome-terminal
    ];

    nixpkgs = {
      config = {
        allowUnfree = true;
      };
    };

    programs.direnv = {
      enable = true;
      config.load_dotenv = false;
      nix-direnv.enable = true;
    };

    programs.mpv = {
      enable = true;
      config = {
        osd-font = "Sans";
        osd-status-msg = "\${playback-time/full} / \${duration} (\${percent-pos}%)\\nframe: \${estimated-frame-number} / \${estimated-frame-count}";
        gpu-api = "auto";
        gpu-context = "auto";
        vo = "gpu";
        dither-depth = 8;
        scale = "lanczos";
        script-opts = "ytdl_hook-ytdl_path=yt-dlp";
      };
    };

    # Breaks speakers.
    # services.easyeffects.enable = true;

    home.packages = with pkgs; [
      celluloid
      fcitx5-configtool
      fcitx5-gtk
      gcolor3
      gimp
      git-crypt
      gnome-disk-utility
      gnome-power-manager
      gnome-tweaks
      go
      gopls
      gotools
      gotab
      fzf
      dissent
      # armcord
      # legcord
      signal-desktop
      mission-center
      jq
      htop
      dnsutils
      keepassxc
      komikku
      nix-output-monitor
      oxfs
      helvum
      pavucontrol
      playerctl
      qalculate-gtk
      silver-searcher
      virt-manager
      waypipe
      wl-clipboard
      telegram-desktop
      # libreoffice-fresh

      # (callPackage ./packages/spot-git.nix { })
    ];
    home.stateVersion = "23.11";

    fonts.fontconfig.enable = true;

    xdg = {
      enable = true;
      mime.enable = true;
      configFile = {
        "nixpkgs/config.nix".text = "{ allowUnfree = true; }";
      };
    };
  };
}
