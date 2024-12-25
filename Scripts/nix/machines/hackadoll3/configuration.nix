# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  config,
  self,
  pkgs,
  lib,
  ...
}:

let
  utils = import <dotfiles/utils> { inherit config pkgs lib; };

  # GIMP v2.99 Nixpkgs
  gimpMesonPkgs = import (pkgs.fetchFromGitHub {
    owner = "jtojnar";
    repo = "nixpkgs";
    rev = "6cb2cce589e1effb0f9983d99132c4f8cc2f4d32"; # gimp-meson
    sha256 = "0wg44l0lkrymsp68s10sx1r4fqd3yvn0lswkhn1zkd3qv6s42nmd";
  }) { };

  gnome-41 = import (pkgs.fetchFromGitHub {
    owner = "NixOS";
    repo = "nixpkgs";
    rev = "3fdd780";
    sha256 = lib.fakeSha256;
  }) { };

  userEnv = {
    LC_TIME = "en_GB.UTF-8";
    NIX_AUTO_RUN = "1";
    # STEAM_RUNTIME = "0";
    # XDG_CURRENT_DESKTOP = "Wayfire";

    GOPATH = "/home/diamond/.go";
    GOBIN = "/home/diamond/.go/bin";
    CGO_ENABLED = "0";

    # Disable VSync.
    vblank_mode = "0";

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
    <home-manager/nixos>
    ./hardware-configuration.nix
    ./services
    ./www
    <dotfiles/overlays>
    <dotfiles/overlays/services.nix>
    <dotfiles/secrets>
    <dotfiles/cfg/v4l2>
    <dotfiles/cfg/udev>
    <dotfiles/cfg/sound>
    <dotfiles/cfg/nokbd>
    <dotfiles/cfg/fonts>
    <dotfiles/cfg/locale>
    <dotfiles/cfg/localhost>
    <dotfiles/cfg/networking>
    <dotfiles/cfg/keyd>
    <dotfiles/cfg/avahi>
    <dotfiles/cfg/gps>
    <dotfiles/cfg/gnome>
    <dotfiles/cfg/flatpak>
    <dotfiles/cfg/dol-server>
    <dotfiles/cfg/secureboot>
    <dotfiles/cfg/foot>
    <dotfiles/cfg/u2f>
    <dotfiles/cfg/steam>
    <dotfiles/cfg/nushell>

    # This shit's still garbage.
    # <dotfiles/cfg/wayfire>
    # <dotfiles/cfg/greetd>
  ];

  nixpkgs.overlays = import ./overlays;
  nixpkgs.config = {
    allowUnfree = true;
  };

  # Remote build server.
  nix = {
    # I don't understand the newer versions. Why do they break literally everything? Let's make
    # everything Flakes, but then since they're Flakes now that means they're experimental, so
    # let's break everything! Bruh.
    # package = pkgs.nix_2_3;
    # package = pkgs.nixFlakes;
    buildMachines = [
      # {
      #   hostName = "hanaharu";
      #   systems = [ "x86_64-linux" "i686-linux" ];
      #   maxJobs = 2;
      #   speedFactor = 1;
      #   supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
      # }
      # {
      #   hostName = "bridget";
      #   systems  = [ "aarch64-linux" ];
      #   maxJobs  = 1;
      #   speedFactor = 2;
      #   supportedFeatures = [ "nixos-test" ];
      # }
      # {
      #   hostName = "otokonoko";
      #   systems = [ "x86_64-linux" "i686-linux" ];
      #   maxJobs = 2;
      #   speedFactor = 5;
      #   supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
      # }
    ];
    distributedBuilds = true;
    extraOptions = ''
      builders-use-substitutes = true
    '';
    registry = builtins.fromJSON (builtins.readFile ./hackadoll3.registry.json);
    settings = {
      substituters = [
        # Cachix uses zstd, which Nix 2.3 does not support. Disable it.
        # "https://nix-community.cachix.org"
        "https://cache.nixos.org/"
      ];
      trusted-users = [
        "root"
        "diamond"
      ];
      trusted-public-keys = [
        # "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };
  };

  # Allow aarch64 emulation.
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  # Group to change SSH keys to.
  users.groups.ssh-trusted.members = [
    "diamond"
    "root"
  ] ++ (utils.formatInts 1 32 (i: "nixbld${toString i}"));

  # services.ghproxy = {
  #   username = "diamondburned";
  #   address  = "unix:///tmp/ghproxy.sock";
  # };

  # Enable MySQL
  # services.postgresql = {
  #   enable = true;
  #   enableTCPIP = false;
  #   ensureDatabases = ["facechat"];
  #   ensureUsers = [{
  #     name = "diamond";
  #     ensurePermissions = {
  #       "DATABASE facechat" = "ALL PRIVILEGES";
  #     };
  #   }];
  #   initialScript = pkgs.writeText "init.sql" ''
  #     CREATE USER diamond;
  #     ALTER  USER diamond WITH SUPERUSER;
  #   '';
  # };

  # NTFS support
  boot.supportedFilesystems = [
    "exfat"
    "ntfs"
  ];

  # Tired of this.
  systemd.extraConfig = ''
    DefaultTimeoutStopSec=5s
  '';

  services.journald.extraConfig = ''
    SystemMaxUse=2G
    MaxRetentionSec=3month
  '';

  networking.hostName = "hackadoll3"; # Define your hostname.

  # This doesn't really work.
  systemd.services.NetworkManager-wait-online.enable = false;

  networking.nat = {
    enable = true;
    internalInterfaces = [ "ve-+" ];
  };

  console.font = "Lat2-Terminus16";
  console.keyMap = "us";

  # services.keyd = {
  #   enable = true;
  #   configuration = {
  #     "default.conf" = ''
  #       [ids]
  #       *
  #       [main]
  #       capslock = esc
  #     '';
  #   };
  # };

  environment.enableDebugInfo = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # System packages
    wget
    nix-index
    nixGL
    # nix-index-update

    # Utilities
    htop
    git
    compsize

    qgnomeplatform
    keyd
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
  };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    ports = [ 22 ];
    settings = {
      PasswordAuthentication = false;
      X11Forwarding = true;
    };
  };

  # Enable CUPS to print documents.
  services.printing = {
    enable = true;
    drivers = with pkgs; [
      # gutenprint
      # hplip
      # cups-filters
      # cups-bjnp

      # Canon
      # cnijfilter2
      # canon-cups-ufr2
    ];
  };

  services.xserver.xkb.layout = "us";

  fonts.fontconfig = {
    enable = true;
    allowBitmaps = true;
    useEmbeddedBitmaps = true; # emojis
    # See fontconfig.xml.
    # subpixel = {
    #   # http://www.spasche.net/files/lcdfiltering/
    #   lcdfilter = "legacy";
    #   rgba = "none";
    # };
    includeUserConf = true;
  };

  security.sudo.extraConfig = ''
    Defaults env_reset,pwfeedback
  '';

  # gnu = true;
  gtk.iconCache.enable = true;

  services.xserver.enable = true;

  services.libinput.enable = true;

  programs.xwayland = {
    enable = true;
    package = pkgs.xwayland.overrideAttrs (old: {
      # preConfigure = (old.preConfigure or "") + ''
      #   patch -p1 < ${./patches/xwayland-fps.patch}
      # '';
    });
  };

  programs.seahorse.enable = true;

  services.gvfs.enable = true;
  programs.gnome-disks.enable = true;
  programs.file-roller.enable = true;

  # dbus things
  services.dbus.packages = with pkgs; [ dconf ];
  programs.dconf.enable = true;

  # Enable Polkit
  security.polkit.enable = true;

  /*
      # Enable MySQL
      services.mysql = {
        enable = true;
        package = pkgs.mariadb;
      };

      services.mysql = {
        enable = true;
        package = pkgs.mariadb;
      };
  */

  virtualisation.docker.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;

  services.sysprof.enable = true;

  virtualisation.libvirtd = {
    enable = true;
    qemu.runAsRoot = false;
  };

  # Enable the Android debug bridge.
  programs.adb.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.diamond = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
      "docker"
      "storage"
      "audio"
      "adbusers"
      "libvirtd"
      "i2c"
      "wireshark"
      "dialout"
      "input"
      "plugdev"
      "photoprism"
    ];
  };

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      # xdg-desktop-portal-gtk
      xdg-desktop-portal-gnome
    ];
  };

  # Enable PAM user environments for GDM.
  security.pam.services.gdm-password.text = ''
    auth      substack      login
    account   include       login
    password  substack      login
    session   include       login
    session   required      pam_env.so user_readenv=1
  '';

  programs.wireshark = {
    enable = true;
    package = pkgs.wireshark-qt;
  };

  programs.command-not-found = {
    enable = true;
    # programs.sqlite is only available if we use the nixos.org channels.
    # See hackadoll3.toml.
    dbPath = "/nix/var/nix/profiles/per-user/root/channels/unstable/programs.sqlite";
  };

  services.earlyoom = {
    enable = true;
    enableNotifications = true;
    freeSwapThreshold = 20;
    freeSwapKillThreshold = 10;
  };

  # Get a newer VTE with SIXEL for ourself.
  # Disabled due to a regression: https://gitlab.gnome.org/GNOME/vte/-/issues/2717.
  # system.replaceRuntimeDependencies = [
  #   {
  #     original = pkgs.vte-gtk4;
  #     replacement = pkgs.callPackage <dotfiles/overlays/packages/vte_sixel.nix> { vte = pkgs.vte-gtk4; };
  #   }
  #   {
  #     original = pkgs.vte;
  #     replacement = pkgs.callPackage <dotfiles/overlays/packages/vte_sixel.nix> { vte = pkgs.vte; };
  #   }
  # ];

  # TODO: fix this:
  # home-manager.useGlobalPkgs = true;

  home-manager.backupFileExtension = "bak";
  home-manager.users.diamond = {
    imports = [ ./home.nix ];
  };

  # system.stateVersion = "20.03"; # DO NOT TOUCH
  system.stateVersion = "20.09"; # I TOUCHED.
}
