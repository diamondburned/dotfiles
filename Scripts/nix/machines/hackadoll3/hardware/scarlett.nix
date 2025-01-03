{
  config,
  lib,
  self,
  pkgs,
  ...
}:

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
      "10-scarlett" = {
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
      "10-scarlett" = {
        "stream.properties" = {
          "node.latency" = "512/48000"; # default
          "resample.quality" = 10;
          # "audio.format" = "S24_LE";
          # "audio.allowed-rates" = allowedSampleRates;
        };
      };
    };
  };

  services.pipewire.wireplumber.extraConfig = {
    "10-scarlett" = {
      "monitor.alsa.rules" = [
        {
          matches = [
            {
              "node.name" = "alsa_output.usb-Focusrite_Scarlett_4i4_4th_Gen_S4JQAWG4884F75-00.*";
            }
          ];
          actions.update-props = {
            "audio.format" = "S24LE";
            "audio.allowed-rates" = allowedSampleRates;
          };
        }
      ];
    };
  };
}
