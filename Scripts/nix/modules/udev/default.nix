{
  config,
  lib,
  pkgs,
  ...
}:

{
  services.udev.extraRules = ''
    ${builtins.readFile ./99-opentabletdriver.rules}
    ${builtins.readFile ./99-vial.rules}
  '';
}
