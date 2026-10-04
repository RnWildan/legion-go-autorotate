#!/usr/bin/env bash
if pgrep -f "niri-autorotate.sh" > /dev/null; then
    pkill -f "niri-autorotate.sh"
    pkill -f "monitor-sensor"
    notify-send "Auto-Rotate" "Disabled" --icon=screen-rotation-locked-symbolic
else
    ~/.local/bin/niri-autorotate.sh &
    notify-send "Auto-Rotate" "Enabled" --icon=screen-rotation-symbolic
fi
