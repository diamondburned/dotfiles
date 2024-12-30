{
  config,
  lib,
  pkgs,
  self,
  ...
}:

with lib;
with lib.types;
with builtins;

let
  hostname = config.networking.hostName;

  trailingDot = name: if name == "" then "" else "${name}.";
  trace' = x: trace x x;
in

{
  options.tailnet.serviceProxies = mkOption {
    description = "Declare local services proxied via Tailscale";
    type = attrsOf (
      either str (submodule {
        options = {
          subdomains = mkOption {
            type = types.listOf types.str;
            default = [ ];
            description = "The subdomains to use for the service, or null to use the service name";
          };
          localPort = mkOption {
            type = types.nullOr types.int;
            default = null;
            description = "The port to reverse proxy to";
          };
          caddyConfig = mkOption {
            type = types.str;
            default = "";
            description = "Additional Caddy configuration";
          };
        };
      })
    );
  };

  config = mkIf (config.tailnet.serviceProxies != { }) {
    # Permit Caddy to use Tailscale for its certificates.
    services.tailscale.permitCertUid = "caddy";

    # Disable reloading.
    # This does not work with the Tailscale plugin.
    systemd.services.caddy.reloadIfChanged = lib.mkForce false;
    systemd.services.caddy.serviceConfig.ExecReload = lib.mkForce null;

    services.diamondburned.caddy = {
      enable = true;
      environmentFile = lib.mkDefault self.lib.path.secret "caddy.env";
      configFile = lib.mkDefault (
        pkgs.writeText "Caddyfile" ''
          {
            auto_https off
          }
        ''
      );
      sites.":80" = mapAttrsToList (
        name: service:
        let
          hosts = if (lib.isAttrs service && service.subdomains != [ ]) then service.subdomains else [ name ];
        in
        ''
          bind ${concatStringsSep " " (map (host: "tailscale/${host}") hosts)}
          tailscale_auth
          ${
            if (isString service) then
              service
            else
              ''
                ${optionalString (service.localPort != null) ''
                  reverse_proxy * localhost:${toString service.localPort} {
                    header_up X-WebAuth-User {http.auth.user.tailscale_login}
                    header_up X-WebAuth-Name {http.auth.user.tailscale_name}
                    header_up X-WebAuth-Email {http.auth.user.tailscale_user}
                  }
                ''}
                ${service.caddyConfig}
              ''
          }
        ''
      ) config.tailnet.serviceProxies;
    };
  };
}
