{
  config,
  lib,
  pkgs,
  self,
  ...
}:

{
  imports = [
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

  users.users.root.openssh.authorizedKeys.keyFiles = [
    "${self}/public_keys"
  ];

  services.openssh = {
    enable = true;
    extraConfig = ''
      ClientAliveInterval 30
      ClientAliveCountMax 100
      AllowTcpForwarding yes
      PasswordAuthentication no
    '';
    knownHosts = (import ./secrets/ssh.nix).knownHosts;
  };
}
