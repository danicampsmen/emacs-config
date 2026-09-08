#!/usr/bin/env bash
# ==============================================================================
# Selector y Gestor de Perfiles de Brillo de Pantalla para Waybar & Hyprland
# Lenovo Yoga 9 (15IMH5) - Panel 4K
# ==============================================================================
set -euo pipefail

# Definición de perfiles: valor_porcentaje|etiqueta|icono
PROFILES=(
    "100|☀️ 100% - Máximo / Exterior|display-brightness-high"
    "85|☀️  85% - Muy Alto / Luz de Día|display-brightness-high"
    "70|☀️  70% - Trabajo / Oficina Iluminada|display-brightness-high"
    "50|🌤️  50% - Equilibrado / Interiores|display-brightness-medium"
    "35|⛅  35% - Moderado / Tarde|display-brightness-medium"
    "20|🌙  20% - Tenue / Noche|display-brightness-low"
    "10|🌑  10% - Mínimo / Ahorro Batería|display-brightness-low"
    "5|🕯️   5% - Ultra Bajo / Habitación Oscura|display-brightness-low"
)

get_current_percent() {
    local cur max
    cur=$(brightnessctl get 2>/dev/null || echo 200)
    max=$(brightnessctl max 2>/dev/null || echo 400)
    if [ "$max" -gt 0 ]; then
        echo $(( cur * 100 / max ))
    else
        echo 50
    fi
}

set_brightness_profile() {
    local val="$1"
    local label=""
    local icon="display-brightness"

    for item in "${PROFILES[@]}"; do
        IFS="|" read -r p_val p_label p_icon <<< "$item"
        if [ "$p_val" -eq "$val" ] 2>/dev/null; then
            label="$p_label"
            icon="$p_icon"
            break
        fi
    done

    if [ -z "$label" ]; then
        label="Brillo al ${val}%"
    fi

    # Aplicar brillo
    brightnessctl set "${val}%" >/dev/null 2>&1 || true

    # Notificación OSD elegante con Mako
    notify-send -h string:x-canonical-private-synchronous:brightness-profile \
                -h int:value:"$val" \
                -i "$icon" \
                -t 1200 \
                "Brillo de Pantalla" "$label"

    # Actualizar Waybar si está activo
    pkill -RTMIN+4 waybar 2>/dev/null || true
}

cycle_next() {
    local cur
    cur=$(get_current_percent)
    local count=${#PROFILES[@]}
    local next_val=""

    # Encontrar el perfil más cercano inmediatamente inferior o ciclar al inicio (100%)
    for i in "${!PROFILES[@]}"; do
        IFS="|" read -r p_val _ _ <<< "${PROFILES[$i]}"
        if [ "$cur" -ge "$p_val" ]; then
            local next_idx=$(( (i + 1) % count ))
            IFS="|" read -r next_val _ _ <<< "${PROFILES[$next_idx]}"
            break
        fi
    done

    if [ -z "$next_val" ]; then
        IFS="|" read -r next_val _ _ <<< "${PROFILES[0]}"
    fi

    set_brightness_profile "$next_val"
}

interactive_menu() {
    local cur
    cur=$(get_current_percent)
    local options=""

    # Determinar qué perfil está más cercano al actual
    local best_diff=999
    local best_idx=0
    for i in "${!PROFILES[@]}"; do
        IFS="|" read -r p_val _ _ <<< "${PROFILES[$i]}"
        local diff=$(( cur > p_val ? cur - p_val : p_val - cur ))
        if [ "$diff" -lt "$best_diff" ]; then
            best_diff=$diff
            best_idx=$i
        fi
    done

    for i in "${!PROFILES[@]}"; do
        IFS="|" read -r p_val label _ <<< "${PROFILES[$i]}"
        if [ "$i" -eq "$best_idx" ]; then
            options+="${label}  [ACTUAL: ${cur}% ✓]\n"
        else
            options+="${label}\n"
        fi
    done

    local selected
    selected=$(echo -en "$options" | rofi -dmenu \
                                         -p "Perfil de Brillo" \
                                         -l 8 \
                                         -i || true)

    if [ -z "$selected" ]; then
        exit 0
    fi

    for item in "${PROFILES[@]}"; do
        IFS="|" read -r p_val label _ <<< "$item"
        if echo "$selected" | grep -q "^${label}"; then
            set_brightness_profile "$p_val"
            exit 0
        fi
    done
}

case "${1:-}" in
    --current)
        get_current_percent
        ;;
    --next)
        cycle_next
        ;;
    --set)
        set_brightness_profile "${2:-50}"
        ;;
    --menu|*)
        interactive_menu
        ;;
esac
