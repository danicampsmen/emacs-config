#!/usr/bin/env bash
# Auto-rotación para Lenovo Yoga 9 en Hyprland usando monitor-sensor

MONITOR="eDP-1"
SCALE="1.5"
RES="3840x2160@60"
POS="0x0"

monitor-sensor --accel 2>/dev/null | while read -r line; do
    case "$line" in
        *"orientation changed: normal"*)
            hyprctl keyword monitor "$MONITOR,$RES,$POS,$SCALE,transform,0"
            ;;
        *"orientation changed: bottom-up"*)
            hyprctl keyword monitor "$MONITOR,$RES,$POS,$SCALE,transform,2"
            ;;
        *"orientation changed: right-up"*)
            hyprctl keyword monitor "$MONITOR,$RES,$POS,$SCALE,transform,1"
            ;;
        *"orientation changed: left-up"*)
            hyprctl keyword monitor "$MONITOR,$RES,$POS,$SCALE,transform,3"
            ;;
    esac
done
