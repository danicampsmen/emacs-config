#!/usr/bin/env bash
# ==============================================================================
# theme-dynamic.sh - Generador de colores dinámicos (Material You) con Matugen
# ==============================================================================

# Si está activo un tema estático (ej. Catppuccin Macchiato), no sobrescribir
if [ -f "$HOME/.config/hypr/theme-static" ]; then
    echo "Tema estático activo (~/.config/hypr/theme-static). Preservando Catppuccin Macchiato."
    exit 0
fi

IMG="$1"
if [ -z "$IMG" ] || [ ! -f "$IMG" ]; then
    # Extraer fondo actual de hyprpaper.conf
    IMG=$(grep -E "^preload\s*=" "$HOME/.config/hypr/hyprpaper.conf" | head -n 1 | cut -d'=' -f2 | xargs)
fi

if [ -z "$IMG" ] || [ ! -f "$IMG" ]; then
    echo "Error: No se encontró la imagen de fondo: $IMG" >&2
    exit 1
fi

MATUGEN="$HOME/.local/bin/matugen"
if [ ! -x "$MATUGEN" ]; then
    echo "Error: Matugen no encontrado en $MATUGEN" >&2
    exit 1
fi

# Extraer colores en formato JSON
DATA=$("$MATUGEN" image --source-color-index 0 "$IMG" -j hex 2>/dev/null)
if [ -z "$DATA" ]; then
    echo "Error: Matugen no pudo procesar la imagen." >&2
    exit 1
fi

# Rutas de destino
COLORS_CSS="$HOME/.config/hypr/colors.css"
COLORS_CONF="$HOME/.config/hypr/colors.conf"

# Generar archivo CSS para Waybar y SwayNC
echo "$DATA" | jq -r '
  .colors as $c |
  "/* Generado automáticamente por theme-dynamic.sh (Matugen) */",
  "@define-color primary \($c.primary.dark.color);",
  "@define-color on_primary \($c.on_primary.dark.color);",
  "@define-color secondary \($c.secondary.dark.color);",
  "@define-color tertiary \($c.tertiary.dark.color);",
  "@define-color surface \($c.surface.dark.color);",
  "@define-color surface_container rgba(255, 255, 255, 0.06);",
  "@define-color on_surface \($c.on_surface.dark.color);",
  "@define-color outline \($c.outline.dark.color);",
  "@define-color error \($c.error.dark.color);"
' > "$COLORS_CSS"

# Generar archivo de configuración para Hyprland
echo "$DATA" | jq -r '
  .colors as $c |
  "# Generado automáticamente por theme-dynamic.sh (Matugen)",
  "$primary = rgb(\($c.primary.dark.color | ltrimstr("#")))",
  "$on_primary = rgb(\($c.on_primary.dark.color | ltrimstr("#")))",
  "$secondary = rgb(\($c.secondary.dark.color | ltrimstr("#")))",
  "$surface = rgb(\($c.surface.dark.color | ltrimstr("#")))",
  "$outline = rgb(\($c.outline.dark.color | ltrimstr("#")))"
' > "$COLORS_CONF"

# Recargar componentes gráficos en caliente
killall -SIGUSR2 waybar 2>/dev/null || true
if command -v swaync-client >/dev/null 2>&1; then
    swaync-client --reload-css 2>/dev/null || true
fi
hyprctl reload 2>/dev/null || true

# Notificación al usuario
notify-send \
    -a "Tema Dinámico" \
    -i "$IMG" \
    -u low \
    "Colores Dinámicos Aplicados" \
    "Paleta Material You adaptada a $(basename "$IMG")"
