{
  config,
  lib,
  self,
  pkgs,
  ...
}:

with builtins;
with lib;

let
  allowedSampleRates = [
    44100
    48000
    88200
    96000
    176400
    192000
  ];
in

{
  imports = [
    self.nixosModules.sound
  ];

  services.pipewire.extraConfig = {
    pipewire = {
      "99-scarlett" = {
        "context.properties" = {
          "default.clock.quantum" = 512;
          "default.clock.min-quantum" = 32;
          "default.clock.max-quantum" = 1024;
          "default.clock.rate" = 48000;
          "default.clock.allowed-rates" = allowedSampleRates;
        };
      };
    };
    pipewire-pulse = {
      "99-scarlett" = {
        "stream.properties" = {
          "node.latency" = "512/48000"; # default
          "resample.quality" = 10;
        };
      };
    };
  };

  services.pipewire.wireplumber.configPackages = [
    (pkgs.writeTextDir "share/wireplumber/main.lua.d/99-scarlett.lua" ''
      alsa_monitor.rules = {
        {
          matches = {{{ "node.name", "matches", "~alsa_output.usb-Focusrite_Scarlett_4i4_4th_Gen_S4JQAWG4884F75-00.*" }}};
          apply_properties = {
            ["audio.format"] = "S24LE",
            ["audio.rate"] = 48000,
            ["audio.allowed-rates"] = { ${concatStringsSep ", " (map toString allowedSampleRates)} },
            ["api.alsa.period-num"] = 2,
            ["api.alsa.period-size"] = 2,
          },
        },
      }
    '')
  ];

  environment.systemPackages = with pkgs; [
    alsa-scarlett-gui
  ];
}
