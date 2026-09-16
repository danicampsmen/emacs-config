#!/usr/bin/env bash
# ==============================================================================
# wallpaper.sh - Selector de fondo de pantalla con cambio de tema dinámico
# ==============================================================================

BG_DIRS=(
    "/usr/share/backgrounds"
    "$HOME/Imágenes/Fondos"
    "$HOME/Pictures/Wallpapers"
)

# Si se pasa una imagen como argumento directo
if [ -n "$1" ] && [ -f "$1" ]; then
    CHOSEN="$1"
else
    # Buscar imágenes válidas
    FILES=""
    for d in "${BG_DIRS[@]}"; do
        if [ -d "$d" ]; then
            FILES+=$(find "$d" -maxdepth 2 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) 2>/dev/null)$'\n'
        fi
    done

    # Filtrar vacíos y mostrar en rofi
    CHOSEN=$(echo "$FILES" | grep -v "^$" | rofi -dmenu -i -p "󰸉 Elegir Fondo" -matching fuzzy)
fi

[ -z "$CHOSEN" ] && exit 0
[ ! -f "$CHOSEN" ] && exit 1

# 1. Aplicar en vivo en hyprpaper
hyprctl hyprpaper wallpaper "eDP-1,$CHOSEN" 2>/dev/null || true

# 2. Hacer persistente en hyprpaper.conf
CONF="$HOME/.config/hypr/hyprpaper.conf"
cat <<EOF > "$CONF"
# Preload wallpaper
preload = $CHOSEN

# Set wallpaper for monitor eDP-1
wallpaper = eDP-1,$CHOSEN

# IPC enabled for dynamic changes
ipc = on
EOF

# 3. Actualizar la paleta de colores dinámicos (Material You)
if [ -x "$HOME/.config/hypr/scripts/theme-dynamic.sh" ]; then
    "$HOME/.config/hypr/scripts/theme-dynamic.sh" "$CHOSEN"
fi
