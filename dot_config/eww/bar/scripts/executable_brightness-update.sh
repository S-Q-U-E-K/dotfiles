#!/usr/bin/env bash


if [[ "$1" == "--down" ]]; then
/usr/bin/eww -c /home/zekea/.config/eww/bar update br_reveal="true"
brightnessctl set 5%-
OLD_SCRIPT_PID=$(cat /home/zekea/.cache/eww_bright_update_script)
kill $OLD_SCRIPT_PID
echo $$ > /home/zekea/.cache/eww_bright_update_script
sleep 1
/usr/bin/eww -c /home/zekea/.config/eww/bar update br_reveal="false"
elif [[ "$1" == "--up" ]]; then
/usr/bin/eww -c /home/zekea/.config/eww/bar update br_reveal="true"
brightnessctl set +5%
OLD_SCRIPT_PID=$(cat /home/zekea/.cache/eww_bright_update_script)
kill $OLD_SCRIPT_PID
echo $$ > /home/zekea/.cache/eww_bright_update_script
sleep 1
/usr/bin/eww -c /home/zekea/.config/eww/bar update br_reveal="false"
fi
