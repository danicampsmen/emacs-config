#!/usr/bin/env bash
# ==============================================================================
# Selector y Gestor de Perfiles de Audio Dolby Atmos / PipeWire para Lenovo Yoga 9
# ==============================================================================
set -euo pipefail

# Definición de perfiles: nombre_sink|etiqueta_amigable|icono
PROFILES=(
    "dolby_dynamic|⚡ Dolby Atmos - Dinámico|audio-speakers"
    "dolby_basshead|🔥 Subwoofer Punch / Bass Pro|audio-subwoofer"
    "dolby_movie|🎬 Dolby Atmos - Películas|video-display"
    "dolby_music|🎵 Dolby Atmos - Música Hi-Fi|audio-headphones"
    "dolby_game|🎮 Dolby Atmos - Juegos|input-gaming"
    "dolby_voice|🎙️ Dolby Atmos - Voz / Diálogo|audio-input-microphone"
    "linux_default_flat|🔈 Modo Plano (Por Defecto Linux)|audio-card-analog"
)

get_current_sink() {
    pactl get-default-sink 2>/dev/null || echo "dolby_dynamic"
}

get_current_profile_label() {
    local cur
    cur=$(get_current_sink)
    for item in "${PROFILES[@]}"; do
        IFS="|" read -r sink_name label icon <<< "$item"
        if [ "$sink_name" = "$cur" ]; then
            echo "$label"
            return 0
        fi
    done
    echo "⚡ Dolby Atmos"
}

get_current_profile_short() {
    local cur
    cur=$(get_current_sink)
    case "$cur" in
        dolby_dynamic) echo "⚡ Dinámico" ;;
        dolby_basshead) echo "🔥 Basshead" ;;
        dolby_movie) echo "🎬 Películas" ;;
        dolby_music) echo "🎵 Música" ;;
        dolby_game) echo "🎮 Juegos" ;;
        dolby_voice) echo "🎙️ Voz" ;;
        linux_default_flat) echo "🔈 Plano" ;;
        *) echo "⚡ Dolby" ;;
    esac
}

set_profile() {
    local target_sink="$1"
    local target_label=""
    local target_icon="audio-speakers"

    for item in "${PROFILES[@]}"; do
        IFS="|" read -r s_name label icon <<< "$item"
        if [ "$s_name" = "$target_sink" ]; then
            target_label="$label"
            target_icon="$icon"
            break
        fi
    done

    if [ -z "$target_label" ]; then
        echo "Perfil no reconocido: $target_sink" >&2
        return 1
    fi

    # 1. Obtener el volumen actual del sink por defecto para mantener consistencia
    local cur_vol
    cur_vol=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null | awk '{print int($2 * 100 + 0.5)}')
    if [ -z "$cur_vol" ] || [ "$cur_vol" -le 0 ]; then
        cur_vol=50
    fi

    # 2. Asignar el nuevo sink como predeterminado en PulseAudio y WirePlumber
    pactl set-default-sink "$target_sink" 2>/dev/null || true

    # 3. Igualar el volumen del nuevo perfil al volumen actual
    pactl set-sink-volume "$target_sink" "${cur_vol}%" 2>/dev/null || true

    # 4. Mover todas las aplicaciones cliente activas (Firefox, Spotify, etc.) al nuevo perfil
    # evitando tocar los flujos internos (.output) de los filter-chains
    python3 -c '
import subprocess, re, sys
target = sys.argv[1]
try:
    output = subprocess.check_output(["pactl", "list", "sink-inputs"], text=True)
    current_id = None
    has_app = False
    for line in output.splitlines():
        m = re.match(r"^(?:Entrada del destino|Sink Input) #(\d+)", line)
        if m:
            if current_id and has_app:
                subprocess.run(["pactl", "move-sink-input", current_id, target], capture_output=True)
            current_id = m.group(1)
            has_app = False
        if "application.name =" in line:
            has_app = True
    if current_id and has_app:
        subprocess.run(["pactl", "move-sink-input", current_id, target], capture_output=True)
except Exception:
    pass
' "$target_sink"

    # 5. Sincronizar todos los perfiles de audio al mismo volumen para evitar saltos
    for item in "${PROFILES[@]}"; do
        IFS="|" read -r s_name _ _ <<< "$item"
        pactl set-sink-volume "$s_name" "${cur_vol}%" 2>/dev/null || true
    done

    # 6. Notificación OSD elegante con Mako
    notify-send -h string:x-canonical-private-synchronous:audio-profile \
                -i "$target_icon" \
                -t 1500 \
                "Perfil de Audio" "$target_label"

    # 7. Notificar a Waybar para actualización inmediata
    pkill -RTMIN+1 waybar 2>/dev/null || true
}

cycle_next() {
    local cur
    cur=$(get_current_sink)
    local count=${#PROFILES[@]}
    local next_sink=""
    for i in "${!PROFILES[@]}"; do
        IFS="|" read -r s_name _ _ <<< "${PROFILES[$i]}"
        if [ "$s_name" = "$cur" ]; then
            local next_idx=$(( (i + 1) % count ))
            IFS="|" read -r next_sink _ _ <<< "${PROFILES[$next_idx]}"
            break
        fi
    done
    if [ -z "$next_sink" ]; then
        IFS="|" read -r next_sink _ _ <<< "${PROFILES[0]}"
    fi
    set_profile "$next_sink"
}

interactive_menu() {
    local cur
    cur=$(get_current_sink)
    local options=""

    for item in "${PROFILES[@]}"; do
        IFS="|" read -r s_name label _ <<< "$item"
        if [ "$s_name" = "$cur" ]; then
            options+="${label}  [ACTIVO ✓]\n"
        else
            options+="${label}\n"
        fi
    done

    local selected
    selected=$(echo -en "$options" | rofi -dmenu \
                                         -p "Perfil de Audio" \
                                         -l 8 \
                                         -i || true)

    if [ -z "$selected" ]; then
        exit 0
    fi

    # Extraer el sink correspondiente según la etiqueta seleccionada
    for item in "${PROFILES[@]}"; do
        IFS="|" read -r s_name label _ <<< "$item"
        if echo "$selected" | grep -q "^${label}"; then
            set_profile "$s_name"
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
    dolby_*|linux_default_flat)
        set_profile "$1"
        ;;
    *)
        interactive_menu
        ;;
esac
