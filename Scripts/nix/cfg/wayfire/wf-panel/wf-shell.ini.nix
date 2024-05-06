{ pkgs }:

pkgs.writeText "wf-shell.ini" ''
[background]
image = /home/diamond/Scripts/nix/background.jpg
preserve_aspect = true

[panel]
css_path = ${./wf-panel.css}

autohide = false

battery_icon_invert = false
battery_icon_size = 18
battery_status = 1

clock_font = default
clock_format = %b %d  %H : %M

menu_fuzzy_search = true
menu_icon = ${./menu.png}
menu_logout_command = wlogout

layer = top
launchers_size = 42
minimal_height = 24

# launcher_cmd_1  = @scrot@ -a
# launcher_icon_1 = preferences-desktop-wallpaper-symbolic

network_icon_invert_color = false
network_icon_size = 18
network_status = 0
network_status_font = default
network_status_use_color = true

position = bottom
volume_display_timeout = 2.500000

widgets_left   = menu
widgets_center = window-list
widgets_right  = network battery clock
''
