#!/usr/bin/env bash
# ==============================================================================
# Selector y Gestor de Perfiles JamesDSP / Dolby Atmos para Lenovo Yoga 9
# ==============================================================================
set -euo pipefail

STATE_FILE="$HOME/.config/jamesdsp/.current_profile"
JDSP_BIN="/home/fayfer/.local/bin/jamesdsp"

# Definición de perfiles: nombre_preset|etiqueta_amigable|icono
PROFILES=(
    "Dolby_Atmos_Dynamic|⚡ Dolby Atmos - Dinámico|audio-speakers"
    "Dolby_Atmos_BassPro|🔥 Subwoofer Punch / Bass Pro|audio-subwoofer"
    "Dolby_Atmos_Movie|🎬 Dolby Atmos - Películas|video-display"
    "Dolby_Atmos_Music|🎵 Dolby Atmos - Música Hi-Fi|audio-headphones"
    "Dolby_Atmos_Voice|🎙️ Dolby Atmos - Voz / Diálogo|audio-input-microphone"
    "Modo_Plano|🔈 Modo Plano (Bypass DSP)|audio-card-analog"
)

get_current_preset() {
    if [ -f "$STATE_FILE" ]; then
        cat "$STATE_FILE"
    else
        echo "Dolby_Atmos_Dynamic"
    fi
}

get_current_profile_label() {
    local cur
    cur=$(get_current_preset)
    for item in "${PROFILES[@]}"; do
        IFS="|" read -r preset label icon <<< "$item"
        if [ "$preset" = "$cur" ]; then
            echo "$label"
            return 0
        fi
    done
    echo "⚡ Dolby Atmos"
}

get_current_profile_short() {
    local cur
    cur=$(get_current_preset)
    case "$cur" in
        Dolby_Atmos_Dynamic) echo "⚡ Dinámico" ;;
        Dolby_Atmos_BassPro) echo "🔥 Basshead" ;;
        Dolby_Atmos_Movie)   echo "🎬 Películas" ;;
        Dolby_Atmos_Music)   echo "🎵 Música" ;;
        Dolby_Atmos_Voice)   echo "🎙️ Voz" ;;
        Modo_Plano)          echo "🔈 Plano" ;;
        *)                   echo "⚡ Dolby" ;;
    esac
}

set_profile() {
    local target_preset="$1"
    local target_label=""
    local target_icon="audio-speakers"

    for item in "${PROFILES[@]}"; do
        IFS="|" read -r preset label icon <<< "$item"
        if [ "$preset" = "$target_preset" ]; then
            target_label="$label"
            target_icon="$icon"
            break
        fi
    done

    if [ -z "$target_label" ]; then
        echo "Perfil no reconocido: $target_preset" >&2
        return 1
    fi

    # 1. Cargar el preset en JamesDSP
    "$JDSP_BIN" --load-preset "$target_preset" 2>/dev/null || true
    echo "$target_preset" > "$STATE_FILE"

    # 2. Asegurar que jamesdsp_sink sea el sumidero predeterminado
    pactl set-default-sink jamesdsp_sink 2>/dev/null || true

    # 3. Notificación OSD elegante con Mako
    notify-send -h string:x-canonical-private-synchronous:audio-profile \
                -i "$target_icon" \
                -t 1500 \
                "Perfil JamesDSP" "$target_label"

    # 4. Notificar a Waybar para actualización inmediata (signal 1 = SIGRTMIN+1)
    pkill -RTMIN+1 waybar 2>/dev/null || true
}

cycle_next() {
    local cur
    cur=$(get_current_preset)
    local count=${#PROFILES[@]}
    local next_preset=""
    for i in "${!PROFILES[@]}"; do
        IFS="|" read -r preset _ _ <<< "${PROFILES[$i]}"
        if [ "$preset" = "$cur" ]; then
            local next_idx=$(( (i + 1) % count ))
            IFS="|" read -r next_preset _ _ <<< "${PROFILES[$next_idx]}"
            break
        fi
    done
    if [ -z "$next_preset" ]; then
        IFS="|" read -r next_preset _ _ <<< "${PROFILES[0]}"
    fi
    set_profile "$next_preset"
}

interactive_menu() {
    local cur
    cur=$(get_current_preset)
    local options=""

    for item in "${PROFILES[@]}"; do
        IFS="|" read -r preset label _ <<< "$item"
        if [ "$preset" = "$cur" ]; then
            options+="${label}  [ACTIVO ✓]\n"
        else
            options+="${label}\n"
        fi
    done

    local selected
    selected=$(echo -en "$options" | rofi -dmenu \
                                         -p "Perfil JamesDSP" \
                                         -l 6 \
                                         -i || true)

    if [ -z "$selected" ]; then
        exit 0
    fi

    for item in "${PROFILES[@]}"; do
        IFS="|" read -r preset label _ <<< "$item"
        if echo "$selected" | grep -q "^${label}"; then
            set_profile "$preset"
            exit 0
        fi
    done
}

case "${1:-}" in
    --current)
        get_current_profile_short
        ;;
    --current-full)
        get_current_profile_label
        ;;
    --next)
        cycle_next
        ;;
    Dolby_*|Modo_Plano)
        set_profile "$1"
        ;;
    dolby_dynamic)
        set_profile "Dolby_Atmos_Dynamic"
        ;;
    dolby_basshead)
        set_profile "Dolby_Atmos_BassPro"
        ;;
    dolby_movie)
        set_profile "Dolby_Atmos_Movie"
        ;;
    dolby_music)
        set_profile "Dolby_Atmos_Music"
        ;;
    dolby_voice)
        set_profile "Dolby_Atmos_Voice"
        ;;
    linux_default_flat)
        set_profile "Modo_Plano"
        ;;
    *)
        interactive_menu
        ;;
esac
