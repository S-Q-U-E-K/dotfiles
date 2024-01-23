#!/usr/bin/bash
hyprctl --batch "keyword monitor eDP-1,2560x1440@165,0x400,1.6,mirror,DP-2 ; dispatch workspace name:lock"
kitty --class=lockscreen --start-as=fullscreen bash -c "sleep 0.5; cbonsai --life 40 --multiplier 5 --time 1 -li" &
sleep 0.5
kitty bash -c "swaylock"
killall cbonsai
hyprctl dispatch workspace 1
hyprctl keyword monitor eDP-1,2560x1440@165,0x400,1.6
