{
  config,
  lib,
  pkgs,
  self,
  inputs,
  ...
}:

let
  inherit (inputs) home-manager;
in

{
  imports = [
    home-manager.nixosModules.home-manager
    self.nixosModules.packages
  ];

  nixpkgs = {
    overlays = [
      self.overlays.overrides
      self.overlays.packages
    ];
    config = {
      allowUnfree = true;
    };
  };

  home-manager.sharedModules = [
    {
      nixpkgs = {
        overlays = [
          self.overlays.overrides
          self.overlays.packages
        ];
        config = {
          allowUnfree = true;
        };
      };
    }
  ];

  home-manager.extraSpecialArgs = {
    inherit self inputs;
  };

  home-manager.users.diamond = {
    imports = [
      self.homeModules.schedules
    ];

    # Automatically push dotfiles.
    services.user.schedules."dotfiles-pusher" = {
      description = "Automatically push dotfiles";
      calendar = "hourly";
      script = ''
        cd ~/ && git add -A && git commit -m Update && git pull --rebase && git push origin
        exit 0
      '';
    };
  };

  hardware = {
    enableAllFirmware = true;
    enableRedistributableFirmware = true;
  };

  nix.settings = {
    substituters = [
      # Prefer Nixpkgs mirror in China over the actual CloudFront one.
      # Surely this is a good idea.
      # "https://mirrors.ustc.edu.cn/nix-channels/store/"
      # "https://mirrors.bfsu.edu.cn/nix-channels/store/"
      "https://cache.nixos.org/"
    ];
    experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

  # Disable split lock detection since it penalizes the performance of certain
  # apps for arbitrary reasons.
  boot.kernelParams = [ "split_lock_detect=off" ];

  users.users.diamond.openssh.authorizedKeys.keyFiles = [
    "${self}/public_keys"
  ];
}
