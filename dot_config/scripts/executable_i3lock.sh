#!/bin/sh -e

# Take a screenshot
scrot /tmp/screen_locked.png

# Pixellate it 10x
mogrify -scale 10% -scale 1000% /tmp/screen_locked.png

# Lock screen displaying this image.
i3lock -i /tmp/screen_locked.png

# Delete image so a new one can be used on next lock
sleep 0.5
rm /tmp/screen_locked*

# Turn the screen off after a delay.
sleep 60; pgrep i3lock && xset dpms force off
