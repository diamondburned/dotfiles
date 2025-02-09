{
  config,
  lib,
  pkgs,
  self,
  ...
}:

let
  userEnv = {
    LC_TIME = "en_GB.UTF-8";
    NIX_AUTO_RUN = "1";
    # STEAM_RUNTIME = "0";
    # XDG_CURRENT_DESKTOP = "Wayfire";

    GOPATH = "/home/diamond/.go";
    GOBIN = "/home/diamond/.go/bin";
    CGO_ENABLED = "0";

    # Disable VSync.
    # vblank_mode = "0";

    # Enforce Wayland.
    NIXOS_OZONE_WL = "1";
    QT_QPA_PLATFORM = "wayland";
    MOZ_ENABLE_WAYLAND = "1";
    # SDL_VIDEODRIVER  = "wayland";

    # GNOME still forces scaling for all Xwayland apps. See
    # https://github.com/ValveSoftware/steam-for-linux/issues/9209.
    STEAM_FORCE_DESKTOPUI_SCALING = "1";

    # osu settings.
    WINE_RT = "89";
    WINE_SRV_RT = "99";
    STAGING_SHARED_MEMORY = "1";
    STAGING_RT_PRIORITY_BASE = "89";
    STAGING_RT_PRIORITY_SERVER = "99";
    STAGING_PA_DURATION = "250000";
    STAGING_PA_PERIOD = "8192";
    STAGING_PA_LATENCY_USEC = "128";
  };
in

{
  imports = [
    self.homeModules.firefox
    self.homeModules.google-chrome
    self.homeModules.blackbox-terminal
    self.homeModules.gnome-terminal
    self.homeModules.git
    self.homeModules.gtk
    self.homeModules.nvim
    self.homeModules.foot
    self.homeModules.gnome
    self.homeModules.fonts
    self.homeModules.zellij
    self.homeModules.flatpak
    self.homeModules.blackbox-terminal
    self.homeModules.dotfiles-pusher
  ];

  nixpkgs.config = {
    overlays = import ./overlays;
    allowUnfree = true;
    # rocmSupport = true;
  };

  programs.direnv = {
    enable = true;
    config = {
      load_dotenv = false;
    };
    nix-direnv.enable = true;
  };

  programs.mpv = {
    enable = true;
    # package = pkgs.mpv-next;
    config = {
      osd-font = "Sans";
      osd-status-msg = "\${playback-time/full} / \${duration} (\${percent-pos}%)\\nframe: \${estimated-frame-number} / \${estimated-frame-count}";
      # profile = "gpu-hq";
      gpu-api = "auto";
      gpu-context = "auto";
      vo = "gpu";
      # vo = "dmabuf-wayland";
      hwdec = "auto-safe";
      dither-depth = "auto";
      # fbo-format = "rgba32f";
      # scale = "lanczos";
      script-opts = "ytdl_hook-ytdl_path=yt-dlp";
    };
  };

  programs.yt-dlp = {
    enable = true;
    extraConfig = ''
      --cookies-from-browser firefox:q1f740f8.default
    '';
  };

  # programs.obs-studio = {
  #   enable  = true;
  #   plugins = with pkgs; [
  #     # obs-backgroundremoval
  #     # obs-studio-plugins.obs-websocket
  #     # obs-wlrobs
  #     # obs-v4l2sink
  #   ];
  # };

  # services.easyeffects.enable = true;

  # home.file.".icons/default/index.theme".text = ''
  #   [icon theme]
  #   Name=Default
  #   Comment=Default Cursor Theme
  #   Inherits=Ardoise_shadow_87
  # '';

  # Home is for no DM, PAM is for gdm.
  # home.sessionVariables = userEnv;         # for no DM.
  pam.sessionVariables = userEnv; # for GDM + GNOME.
  systemd.user.sessionVariables = userEnv; # for GDM + Wayfire.

  home.packages =
    ([
    ])
    ++ (with pkgs.aspellDicts; [
      en
      en-science
      en-computers

    ])
    ++ (with pkgs; [
      # Personal stuff
      pomodoro
      gnome-usage
      pomodoro
      keepassxc
      sticky
      gimp
      git-crypt
      gnupg
      gnuplot
      drawing
      sticky
      fragments
      goatcounter
      alarm-clock-applet
      mixxx

      # System
      deja-dup
      ncdu
      xorg.xhost # dependency for wsudo
      ddcutil
      powertop
      blueberry
      mission-center
      libcanberra-gtk3
      fcitx5-configtool
      fcitx5-gtk
      libsForQt5.fcitx5-qt
      wl-clipboard
      playerctl
      waypipe
      bottles
      # gatttool

      rmtrash
      # Force rm to use rmtrash.
      (pkgs.writeShellScriptBin "rm" ''
        if [[ "$USER" == diamond ]]; then
          exec ${rmtrash}/bin/rmtrash --forbid-root=ask-forbid "$@"
        else
          exec ${pkgs.coreutils}/bin/rm "$@"
        fi
      '')

      # Development tools
      # sommelier
      dos2unix
      (writeShellScriptBin "ag" ''
        exec ${lib.getExe silver-searcher} --noaffinity "$@"
      '')
      jq
      fx
      gh
      go
      gopls
      gotools
      govulncheck
      nixfmt-rfc-style
      mdr
      # config.boot.kernelPackages.perf
      # perf_data_converter
      tree
      fzf
      graphviz
      gnuplot
      vimHugeX
      # clang-tools
      xclip
      virt-manager
      xorg.xauth
      # neovide
      # neovim-gtk

      # Multimedia
      # aqours
      # (succumb-to-libadwaita spot)
      libva-utils
      # catnip-gtk
      ffmpeg
      v4l-utils
      pavucontrol
      pulseaudio
      pamixer
      lollypop
      komikku
      spotify
      spot
      chatterino2

      # Chat/Social
      # zoom-us
      # discord
      discord-canary # working Wayland audio support
      dissent
      # armcord
      # telegram-desktop
      # legcord
      # vesktop
      kotatogram-desktop
      signal-desktop
      # (pkgs.callPackage <unstable/pkgs/by-name/ve/vesktop/package.nix> {})
      # gotktrix
      fractal
      tuba

      # Office
      libreoffice
      qalculate-gtk
      onlyoffice-bin
      evince
      aspell
      graphviz
      # foliate

      # Applications
      gcolor3
      # google-chrome

      # Themes
      papirus-icon-theme
      material-design-icons
      catppuccin-cursors.mochaPink
      catppuccin-cursors.macchiatoPink
      catppuccin-cursors.mochaFlamingo
      catppuccin-cursors.macchiatoFlamingo
      catppuccin-gtk

      # Games
      # polymc
      prismlauncher
      # osu-wine
      # osu-wine-realistik

      # GNOME things
      kooha
      snapshot
      glib-networking
      celluloid
      gnome-power-manager
      eog
      file-roller
      nautilus
      nautilus-open-any-terminal
      gnome-disk-utility
      gnome-tweaks
      gnome-boxes

      (runCommand "diamond-bin" { } ''
        mkdir -p $out/bin
        cp -r ${self.lib.path.bin ""}/* $out/bin
      '')
    ]);

  fonts.fontconfig.enable = lib.mkForce true;

  xdg = {
    enable = true;
    mime.enable = true;
    # mimeApps = {
    #   enable = true;
    #   defaultApplications = {
    #     "default-web-browser" = [ "firefox.desktop" ];
    #   };
    # };
    configFile = {
      "zls.json".text = builtins.toJSON {
        enable_snippets = false;
        zig_exe_path = "${pkgs.zig}/bin/zig";
        zig_lib_path = "${pkgs.zig}/lib/zig";
        warn_style = true;
        enable_semantic_tokens = true;
      };
      "autostart/autostart.desktop".text = lib.x.mkDesktopFile {
        name = "autostart-init";
        exec = self.lib.path.bin "autostart";
        type = "Application";
        comment = "An autostart script in ~/Scripts/nix/bin/autostart";
        extraEntries = ''
          NotShowIn=desktop-name
          X-GNOME-Autostart-enabled=true
        '';
      };
      # Allow non-free for user
      "nixpkgs/config.nix".text = "{ allowUnfree = true; }";
      "nix/nix.conf".text = ''
        experimental-features = nix-command flakes
      '';
    };
  };

  home.stateVersion = "20.09";
}
