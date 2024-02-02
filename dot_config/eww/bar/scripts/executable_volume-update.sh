#!/usr/bin/env bash


if [[ "$1" == "--down" ]]; then
/usr/bin/eww -c /home/zekea/.config/eww/bar update vol_reveal="true"
wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%-
OLD_SCRIPT_PID=$(cat /home/zekea/.cache/eww_vol_update_script)
kill $OLD_SCRIPT_PID
echo $$ > /home/zekea/.cache/eww_vol_update_script
sleep 1
/usr/bin/eww -c /home/zekea/.config/eww/bar update vol_reveal="false"
elif [[ "$1" == "--up" ]]; then
/usr/bin/eww -c /home/zekea/.config/eww/bar update vol_reveal="true"
wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+
OLD_SCRIPT_PID=$(cat /home/zekea/.cache/eww_vol_update_script)
kill $OLD_SCRIPT_PID
echo $$ > /home/zekea/.cache/eww_vol_update_script
sleep 1
/usr/bin/eww -c /home/zekea/.config/eww/bar update vol_reveal="false"
fi
