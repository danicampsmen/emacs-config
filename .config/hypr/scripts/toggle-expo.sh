#!/usr/bin/env bash
# ============================================================
# toggle-expo.sh - Control interactivo de HyprExpo
# ============================================================

ACTION="$1"
TARGET_WS="$2"

case "$ACTION" in
    --close)
        hyprctl --batch "dispatch hyprexpo:expo close; dispatch submap reset"
        ;;
    --goto)
        if [[ -n "$TARGET_WS" ]]; then
            hyprctl --batch "dispatch hyprexpo:expo close; dispatch submap reset"
            sleep 0.08
            hyprctl dispatch workspace "$TARGET_WS"
        fi
        ;;
    --toggle|*)
        CURRENT_SUBMAP=$(hyprctl submap -j 2>/dev/null | jq -r '.submap' 2>/dev/null || hyprctl submap 2>/dev/null)
        if [[ "$CURRENT_SUBMAP" == "expo" ]]; then
            hyprctl --batch "dispatch hyprexpo:expo close; dispatch submap reset"
        else
            hyprctl --batch "dispatch hyprexpo:expo toggle; dispatch submap expo"
        fi
        ;;
esac
