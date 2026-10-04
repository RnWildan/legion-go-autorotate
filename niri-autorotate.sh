#!/usr/bin/env bash
OUTPUT="eDP-1"

monitor-sensor 2>/dev/null | while read -r line; do
    case "$line" in
        *"left-up"*)
            niri msg output "$OUTPUT" transform "90"
            ;;
        *"right-up"*)
            niri msg output "$OUTPUT" transform "270"
            ;;
        *"normal"*)
            niri msg output "$OUTPUT" transform "normal"
            ;;
        *"bottom-up"*)
            niri msg output "$OUTPUT" transform "180"
            ;;
    esac
done
