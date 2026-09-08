#!/usr/bin/env bash
# Script para iniciar/detener grabación de pantalla en Hyprland con wf-recorder

if pgrep -x "wf-recorder" > /dev/null; then
    killall -s SIGINT wf-recorder
    notify-send -t 3000 "Grabación detenida" "El vídeo se ha guardado en ~/Vídeos"
else
    DEST_DIR="$HOME/Vídeos"
    mkdir -p "$DEST_DIR"
    FILE="$DEST_DIR/grabacion_$(date +'%Y-%m-%d_%H-%M-%S').mp4"
    GEOM=$(slurp)
    if [ -n "$GEOM" ]; then
        notify-send -t 2000 "Grabando pantalla" "Presiona Super+Print para detener"
        wf-recorder -g "$GEOM" -f "$FILE"
    fi
fi
