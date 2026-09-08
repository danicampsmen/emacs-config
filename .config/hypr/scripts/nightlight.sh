#!/usr/bin/env bash
# ==============================================================================
# Gestor y Selector de Perfiles de Calidez / Modo Nocturno para Waybar & Hyprland
# Basado en sunsetr con backend nativo Hyprland CTM (hyprland_ctm_control_manager_v1)
# ==============================================================================
set -euo pipefail

STATE_FILE="${HOME}/.cache/nightlight_state"
SUNSETR_BIN="${HOME}/.local/bin/sunsetr"
if [ ! -x "$SUNSETR_BIN" ]; then
    SUNSETR_BIN="$(command -v sunsetr 2>/dev/null || true)"
fi

is_running() {
    "$SUNSETR_BIN" status 2>&1 | grep -q "Active preset:"
}

ensure_running() {
    if ! is_running; then
        rm -f "/run/user/${UID}/sunsetr"*.lock "/run/user/${UID}/sunsetr"*.sock 2>/dev/null || true
        "$SUNSETR_BIN" -b >/dev/null 2>&1 || true
        for _ in {1..20}; do
            if is_running; then break; fi
            sleep 0.05
        done
    fi
}

get_preset() {
    if ! is_running; then
        echo "6500k"
        return
    fi
    local p
    p=$("$SUNSETR_BIN" status 2>/dev/null | awk '/Active preset:/ {print $3}')
    echo "${p:-default}"
}

get_state_label() {
    local p
    p=$(get_preset)
    case "$p" in
        "6500k")
            echo "Desactivado (6500K)"
            ;;
        "default")
            local temp
            temp=$("$SUNSETR_BIN" status 2>/dev/null | awk '/Temperature:/ {print $2}')
            echo "Auto (${temp:-4000K})"
            ;;
        "5000k")
            echo "5000K"
            ;;
        "4000k")
            echo "4000K"
            ;;
        "3200k")
            echo "3200K"
            ;;
        "2500k")
            echo "2500K"
            ;;
        *)
            echo "$p"
            ;;
    esac
}

apply_preset() {
    local preset="$1"
    local label="$2"

    ensure_running
    "$SUNSETR_BIN" preset "$preset" >/dev/null 2>&1 || true

    echo "$label" > "$STATE_FILE"

    local notif_icon="weather-clear-night"
    if [ "$preset" = "6500k" ]; then
        notif_icon="display-brightness"
    fi

    notify-send -h string:x-canonical-private-synchronous:nightlight \
                -i "$notif_icon" \
                -t 1500 \
                "Perfil de Calidez" "$label"

    # Actualizar Waybar inmediatamente
    pkill -RTMIN+2 waybar 2>/dev/null || true
}

toggle() {
    local cur
    cur=$(get_preset)
    if [ "$cur" = "6500k" ]; then
        apply_preset "default" "Modo Automático (Atardecer/Amanecer)"
    else
        apply_preset "6500k" "Desactivado (6500K - Normal)"
    fi
}

cycle_next() {
    local cur
    cur=$(get_preset)
    case "$cur" in
        "6500k")
            apply_preset "default" "Modo Automático (Atardecer/Amanecer)"
            ;;
        "default")
            apply_preset "5000k" "Luz Cálida Suave (5000K)"
            ;;
        "5000k")
            apply_preset "4000k" "Luz Nocturna Estándar (4000K)"
            ;;
        "4000k")
            apply_preset "3200k" "Luz Cálida Fuerte (3200K)"
            ;;
        "3200k")
            apply_preset "2500k" "Modo Lectura Profunda (2500K)"
            ;;
        "2500k"|*)
            apply_preset "6500k" "Desactivado (6500K - Normal)"
            ;;
    esac
}

menu() {
    ensure_running
    local cur
    cur=$(get_preset)
    local options=""

    if [ "$cur" = "6500k" ]; then
        options+="☀️ Desactivar modo nocturno (6500K - Normal)  [ACTIVO ✓]\n"
    else
        options+="☀️ Desactivar modo nocturno (6500K - Normal)\n"
    fi

    if [ "$cur" = "default" ]; then
        options+="🌙 Modo Automático (Atardecer/Amanecer)  [ACTIVO ✓]\n"
    else
        options+="🌙 Modo Automático (Atardecer/Amanecer)\n"
    fi

    if [ "$cur" = "5000k" ]; then
        options+="🌅 Luz Cálida Suave (5000K)  [ACTIVO ✓]\n"
    else
        options+="🌅 Luz Cálida Suave (5000K)\n"
    fi

    if [ "$cur" = "4000k" ]; then
        options+="🌙 Luz Nocturna Estándar (4000K)  [ACTIVO ✓]\n"
    else
        options+="🌙 Luz Nocturna Estándar (4000K)\n"
    fi

    if [ "$cur" = "3200k" ]; then
        options+="🕯️ Luz Cálida Fuerte (3200K)  [ACTIVO ✓]\n"
    else
        options+="🕯️ Luz Cálida Fuerte (3200K)\n"
    fi

    if [ "$cur" = "2500k" ]; then
        options+="📖 Modo Lectura Profunda (2500K)  [ACTIVO ✓]\n"
    else
        options+="📖 Modo Lectura Profunda (2500K)\n"
    fi

    pkill -x rofi 2>/dev/null || true

    local selected
    selected=$(echo -en "$options" | rofi -dmenu \
                                         -p "Perfil de Calidez" \
                                         -l 6 \
                                         -i \
                                         -theme-str 'window {width: 440px;}' || true)

    if [ -z "$selected" ]; then
        exit 0
    fi

    case "$selected" in
        *"Desactivar"*)
            apply_preset "6500k" "Desactivado (6500K - Normal)"
            ;;
        *"Automático"*)
            apply_preset "default" "Modo Automático (Atardecer/Amanecer)"
            ;;
        *"5000K"*)
            apply_preset "5000k" "Luz Cálida Suave (5000K)"
            ;;
        *"4000K"*)
            apply_preset "4000k" "Luz Nocturna Estándar (4000K)"
            ;;
        *"3200K"*)
            apply_preset "3200k" "Luz Cálida Fuerte (3200K)"
            ;;
        *"2500K"*)
            apply_preset "2500k" "Modo Lectura Profunda (2500K)"
            ;;
    esac
}

status_json() {
    local p
    p=$(get_preset)
    local cur_label
    cur_label=$(get_state_label)

    if [ "$p" != "6500k" ] && is_running; then
        cat <<EOF
{"text": "", "tooltip": "Perfil de Calidez: ACTIVO ($cur_label)\n• Clic izquierdo: Selector de perfiles de calidez\n• Clic derecho: Alternar encendido/apagado", "class": "on"}
EOF
    else
        cat <<EOF
{"text": "󰖔", "tooltip": "Perfil de Calidez: DESACTIVADO (6500K - Normal)\n• Clic izquierdo: Selector de perfiles de calidez\n• Clic derecho: Alternar encendido/apagado", "class": "off"}
EOF
    fi
}

case "${1:-}" in
    --toggle)
        toggle
        ;;
    --next)
        cycle_next
        ;;
    --off)
        apply_preset "6500k" "Desactivado (6500K - Normal)"
        ;;
    --auto)
        apply_preset "default" "Modo Automático (Atardecer/Amanecer)"
        ;;
    --temp)
        case "${2:-4000}" in
            6500|6500k) apply_preset "6500k" "Desactivado (6500K - Normal)" ;;
            5000|5000k) apply_preset "5000k" "Luz Cálida Suave (5000K)" ;;
            4000|4000k) apply_preset "4000k" "Luz Nocturna Estándar (4000K)" ;;
            3200|3200k) apply_preset "3200k" "Luz Cálida Fuerte (3200K)" ;;
            2500|2500k) apply_preset "2500k" "Modo Lectura Profunda (2500K)" ;;
            *) apply_preset "4000k" "Luz Nocturna (4000K)" ;;
        esac
        ;;
    --menu)
        menu
        ;;
    --status)
        status_json
        ;;
    *)
        menu
        ;;
esac
