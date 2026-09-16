#!/usr/bin/env bash
# ==============================================================================
# screenshot.sh - Utilidad rápida y robusta de capturas de pantalla para Hyprland
# ==============================================================================

MODE="${1:-screen}"
TARGET_DIR="${XDG_PICTURES_DIR:-$HOME/Imágenes}/Capturas"
mkdir -p "$TARGET_DIR"

TIMESTAMP=$(date +'%Y-%m-%d_%H-%M-%S')
FILE="$TARGET_DIR/Captura_${TIMESTAMP}.png"

case "$MODE" in
    screen|output|full)
        grim "$FILE"
        ;;
    area|region|selection)
        GEOM=$(slurp -b '#12141a88' -c '#51afef' -s '#51afef22' -w 2)
        [ -z "$GEOM" ] && exit 0 # Cancelado por el usuario
        grim -g "$GEOM" "$FILE"
        ;;
    window|active)
        ACTIVE_WIN=$(hyprctl -j activewindow)
        GEOM=$(echo "$ACTIVE_WIN" | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"' 2>/dev/null)
        if [ -n "$GEOM" ] && [ "$GEOM" != "null" ] && [ "$GEOM" != "0,0 0x0" ]; then
            grim -g "$GEOM" "$FILE"
        else
            # Fallback a pantalla completa si no hay ventana activa
            grim "$FILE"
        fi
        ;;
    *)
        grim "$FILE"
        ;;
esac

# Verificar si se generó el archivo correctamente
if [ -f "$FILE" ]; then
    # Copiar al portapapeles
    wl-copy --type image/png < "$FILE"

    # Notificar con vista previa del archivo
    notify-send \
        -a "Captura" \
        -i "$FILE" \
        -u low \
        "Captura de pantalla realizada" \
        "Copiada al portapapeles y guardada en:\n$FILE"
fi
