{
  config,
  lib,
  self,
  pkgs,
  ...
}:

{
  imports = [
    self.nixosModules.sound
  ];

  services.pipewire.extraConfig = {
    pipewire = {
      "10-scarlett" = {
        "context.properties" = {
          # Allow lower latency audio.
          "default.clock.quantum" = 512;
          "default.clock.min-quantum" = 32;
          "default.clock.max-quantum" = 4096;
          # Avoid resampling.
          "default.clock.allowed-rates" = [
            44100
            48000
            88200
            96000
            176400
            192000
          ];
        };
      };
    };
  };

  # services.pipewire.wireplumber.extraConfig = {
  #   "scarlett" = {
  #     "monitor.alsa.rules" = [
  #       {
  #         matches = [
  #           {
  #             "node.name" = "alsa_output.usb-Focusrite_Scarlett_4i4_4th_Gen_S4JQAWG4884F75-00.*";
  #           }
  #         ];
  #         actions.update-props = {
  #         };
  #       }
  #     ];
  #   };
  # };
}
