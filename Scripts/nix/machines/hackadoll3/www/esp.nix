{ config, lib, pkgs, ... }:

let
	index = pkgs.writeText "index.html" ''
		<!DOCTYPE html>
		<title>Tasmota Index</title>
		<meta charset="utf-8">
		<meta name="viewport" content="width=device-width, initial-scale=1">
		<link rel="icon" type="image/png" href="/favicon.png">
		<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/normalize.css@8.0.1/normalize.css">
		<link rel="stylesheet" href="https://markdowncss.github.io/retro/css/retro.css">
		<style>
			body {
				font-family: monospace !important;
			}
		</style>

		<h1>Tasmota Index</h1>
		<ul>
			<li><a href="/bulb">Tasmota Bulb</a></li>
			<li><a href="/plug">Tasmota Plug</a></li>
		</ul>
	'';

	fs = pkgs.runCommandLocal "esp-fs" { } ''
		mkdir -p $out
		ln -s ${index} $out/index.html
		ln -s ${<dotfiles/static/tasmota-white.png>} $out/favicon.png
	'';
in

{
	diamond.tailnetServices.esp = {
		caddyConfig = ''
			redir /bulb http://192.168.2.124:80 302
			redir /plug http://192.168.2.239:80 302
			root * ${fs}
			file_server
		'';
	};
}
