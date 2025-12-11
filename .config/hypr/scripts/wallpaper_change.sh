#!/bin/sh
WALLPAPER=$(grep wallpaper ~/.config/waypaper/config.ini | cut -d'"' -f2)
sed -i "s|path = .*|path = $WALLPAPER|" ~/.config/hypr/hyprlock.conf
