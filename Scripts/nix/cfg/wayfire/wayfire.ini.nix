{ pkgs }:

with pkgs;
with pkgs.lib;

writeText "wayfire.ini" ''
[core]
plugins = \
	animate \
	autostart \
	command \
	decoration \
	fast-switcher \
	idle \
	move \
	grid \
	oswitch \
	place \
	resize \
	switcher \
	vswitch \
	window-rules \
	zoom

vwidth  = 1
vheight = 1

# max_render_time = 12

[autostart]
# Wayfire you piece of shit, literally nothing ever works. Why is this so badly
# designed? I crammed this into a fucking shell script so all it has to do is
# execute a single file, yet it fails to do that properly. Holy fucking shit.
00 = ${writeShellScript "wayfire-autostart" ''
	set +e

	# dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
	# systemctl --user import-environment

	fork() { $@ & disown; }

	echo Forking...

	fork ${getExe dex} -a -s /home/diamond/.config/autostart/
	fork ${getExe walker} --gapplication-service
	fork ${polkit_gnome}/libexec/polkit-gnome-authentication-agent-1
	fork ${xdg-desktop-portal-wlr}/libexec/xdg-desktop-portal-wlr
	fork ${xdg-desktop-portal-gtk}/libexec/xdg-desktop-portal-gtk
	# fork ${wayfirePlugins.wf-shell}/bin/wf-background
	fork ${getExe wlsunset}
	fork ${getExe fcitx5}
	fork ${getExe swaynotificationcenter}
	fork ${getExe xfce.xfce4-panel}

	echo Forked everything.
''}
dbus-uenv = dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
sysd-envv = systemctl --user import-environment

[workarounds]
# use_external_output_configuration = true

[input]
kb_repeat_delay = 200
kb_repeat_rate = 50
xkb_options = caps:escape

middle_emulation = true
mouse_accel_profile = flat
mouse_cursor_speed = 0.1
touchpad_accel_profile = adaptive
click_method = clickfinger
scroll_method = two-finger
natural_scroll = true

# cursor_theme = Ardoise_shadow_87
cursor_theme = Catppuccin-Mocha-Pink-Cursors
cursor_size = 24

[command]
binding_launcher = <super>
command_launcher = ${getExe walker}

# Wayfire recognizes KC_PSCR as KC_SYSREQ for some reason.
binding_scrot = KEY_SYSRQ
command_scrot = ${getExe scrot}

binding_scrot_area = <shift> KEY_SYSRQ
command_scrot_area = ${getExe scrot} -a

binding_play = KEY_PLAYPAUSE
command_play = ${getExe playerctl} play-pause
binding_prev = KEY_PREVIOUSSONG
command_prev = ${getExe playerctl} previous
binding_next = KEY_NEXTSONG
command_next = ${getExe playerctl} next

repeatable_binding_volume_up   = KEY_VOLUMEUP
command_volume_up              = ${getExe pulseaudio} set-sink-volume @DEFAULT_SINK@ +2%
repeatable_binding_volume_down = KEY_VOLUMEDOWN
command_volume_down            = ${getExe pulseaudio} set-sink-volume @DEFAULT_SINK@ -2%
binding_mute                   = KEY_MUTE
command_mute                   = ${getExe pulseaudio} set-sink-mute @DEFAULT_SINK@ toggle

[zoom]
modifier = <alt>
speed = 0.01
smoothing_duration = 150

[move]
activate = <super> BTN_LEFT
enable_snap = true
enable_snap_off = true

[grid]
duration = 150

[resize]
activate = <super> BTN_RIGHT

[animate]
open_animation = zoom
close_animation = zoom
zoom_duration = 100

[wobbly]
friction = 5
spring_k = 50
grid_resolution = 12

[switcher]
speed = 150

[decoration]
# 1D1D1DFF
active_color = 0.114 0.114 0.114 1.0
inactive_color = 0.114 0.114 0.114 1.0
border_size  = 2
title_height = 20

[blur]
method = kawase
''
