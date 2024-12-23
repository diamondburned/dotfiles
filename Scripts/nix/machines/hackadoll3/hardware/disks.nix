{ pkgs, ... }:

let
  sources = import ../../../nix/sources.nix { inherit pkgs; };
  disko = sources.disko;
in

{
  imports = [
    "${disko}/module.nix"
    ./disko/4tb-nvme.nix
  ];

  services.fstrim.enable = true;

  # boot.initrd.luks.devices = {
  #   "hackadoll3-luks" = {
  #     device = "/dev/disk/by-uuid/43c71be8-6364-41e3-98df-026bf3f70dc9";
  #     bypassWorkqueues = true;
  #     crypttabExtraOpts = [
  #       "fido2-device=auto"
  #       "cipher=aes-xts-plain:sha256"
  #       "rd.luks.options=timeout=0"
  #       "rootflags=x-systemd.device-timeout=0"
  #     ];
  #   };
  # };
}
