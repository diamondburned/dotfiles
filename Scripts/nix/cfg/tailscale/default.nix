{ config, lib, pkgs, ... }:

{
	services.tailscale.enable = true;
	services.tailscale.useRoutingFeatures = "client";
}
