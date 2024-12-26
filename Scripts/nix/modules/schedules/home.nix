{
  config,
  pkgs,
  lib,
  ...
}:

with lib;
with builtins;

let
  schedules = config.services.user.schedules;
in

{
  options.services.user.schedules = mkOption {
    description = ''
      Allows users to schedule tasks using systemd timers.
    '';
    type = types.attrsOf (
      types.submodule (
        { name, ... }:
        {
          options = {
            name = mkOption {
              type = types.str;
              default = name;
            };
            description = mkOption {
              type = types.str;
              default = "";
            };
            calendar = mkOption {
              type = types.str;
              description = ''
                A systemd calendar expression. See `man systemd.time` for more information.
              '';
            };
            script = mkOption {
              type = types.str;
              description = ''
                The command to run.
              '';
            };
          };
        }
      )
    );
    default = { };
  };

  config = {
    systemd.user.timers = mapAttrs (name: schedule: {
      Unit = {
        Description = schedule.description;
      };
      Install = {
        WantedBy = [ "timers.target" ];
      };
      Timer = {
        OnCalendar = schedule.calendar;
        Unit = "${name}.service";
      };
    }) schedules;

    systemd.user.services = mapAttrs (name: schedule: {
      Unit = {
        Description = schedule.description;
      };
      Service = {
        Type = "oneshot";
        ExecStart =
          if builtins.isPath schedule.script then
            schedule.script
          else
            pkgs.writeShellScript "${name}.sh" schedule.script;
      };
    }) schedules;
  };
}
