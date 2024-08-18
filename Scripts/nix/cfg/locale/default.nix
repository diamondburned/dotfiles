{ config, lib, pkgs, ... }:

let
	hunspellDicts = with pkgs.hunspellDicts; [
		en-us
		en-us-large
	];

	aspellDicts = with pkgs.aspellDicts; [
		en
		en-science
		en-computers
		vi
	];
in

{
	environment = {
		sessionVariables = {
			# Hunspell support.
			# DICPATH = pkgs.lib.makeSearchPath "share/hunspell" hunspellDicts;
			# Aspell support.
			ASPELL_CONF = "dict-dir ${pkgs.symlinkJoin {
				name = "aspell-dicts";
				paths = aspellDicts;
			}}/lib/aspell";
		};
		systemPackages = with pkgs; [
			# (hunspellWithDicts hunspellDicts)
			# (aspellWithDicts aspellDicts)
		];
	};

	i18n = {
		inputMethod = {
			enable = true;
			type = "fcitx5";

			fcitx5.addons = with pkgs; [
				fcitx5-m17n
				fcitx5-unikey
				fcitx5-gtk
				# fcitx5-mozc
			];
		};

		defaultLocale = "en_US.UTF-8";
		supportedLocales = [
			"en_US.UTF-8/UTF-8"
			"en_GB.UTF-8/UTF-8"
			"ja_JP.UTF-8/UTF-8"
			"vi_VN/UTF-8"
		];
	};
}
