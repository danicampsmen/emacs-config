#!/usr/bin/env bash
# ==============================================================================
# Control de volumen ultrarrápido (pasos de 1%, sin retrasos de repetición)
# Soporte para Mako OSD y Hyprland (Lenovo Yoga 9)
# ==============================================================================
set -euo pipefail

# 1. Evitar acumulación de procesos en cola al mantener presionada la tecla.
# Si ya hay una instancia ejecutándose, se descarta el evento repetido sobrante
# en /dev/shm de forma instantánea sin crear cola.
exec 200>/dev/shm/.volume_control.lock
if ! flock -n 200; then
    exit 0
fi

case "${1:-}" in
    --inc)
        wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 2%+
        if [ "$(pactl get-default-sink 2>/dev/null)" = "jamesdsp_sink" ]; then
            pactl set-sink-volume alsa_output.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__Speaker__sink +2% 2>/dev/null || true
        fi
        ;;
    --dec)
        wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%-
        if [ "$(pactl get-default-sink 2>/dev/null)" = "jamesdsp_sink" ]; then
            pactl set-sink-volume alsa_output.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__Speaker__sink -2% 2>/dev/null || true
        fi
        ;;
    --toggle)
        wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
        if [ "$(pactl get-default-sink 2>/dev/null)" = "jamesdsp_sink" ]; then
            pactl set-sink-mute alsa_output.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__Speaker__sink toggle 2>/dev/null || true
        fi
        ;;
    --toggle-mic)
        wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle
        if wpctl get-volume @DEFAULT_AUDIO_SOURCE@ 2>/dev/null | grep -q "MUTED"; then
            notify-send -h string:x-canonical-private-synchronous:audio-mic \
                        -i microphone-sensitivity-muted \
                        -t 1000 \
                        "Micrófono" "Silenciado" </dev/null >/dev/null 2>&1 &
        else
            notify-send -h string:x-canonical-private-synchronous:audio-mic \
                        -i microphone-sensitivity-high \
                        -t 1000 \
                        "Micrófono" "Activado" </dev/null >/dev/null 2>&1 &
        fi
        exit 0
        ;;
    *)
        exit 0
        ;;
esac

# 2. Obtener volumen y estado de silencio en una sola lectura
raw=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null || echo "Volume: 0.50")
read -r _ val muted <<< "$raw"

vol=50
if [[ "$val" =~ ^([0-9]+)\.([0-9]+) ]]; then
    int_p="${BASH_REMATCH[1]}"
    dec_p="${BASH_REMATCH[2]}"
    if [ ${#dec_p} -eq 1 ]; then
        dec_p="${dec_p}0"
    elif [ ${#dec_p} -gt 2 ]; then
        dec_p="${dec_p:0:2}"
    fi
    vol=$(( 10#$int_p * 100 + 10#$dec_p ))
fi

# 3. Notificación OSD asíncrona (no bloquea la ejecución)
if [ -n "$muted" ]; then
    notify-send -h string:x-canonical-private-synchronous:audio-volume \
                -h int:value:0 \
                -i audio-volume-muted \
                -t 800 \
                "Audio" "Silenciado" </dev/null >/dev/null 2>&1 &
else
    icon="audio-volume-high"
    if (( vol <= 0 )); then
        icon="audio-volume-muted"
    elif (( vol < 30 )); then
        icon="audio-volume-low"
    elif (( vol < 70 )); then
        icon="audio-volume-medium"
    fi
    notify-send -h string:x-canonical-private-synchronous:audio-volume \
                -h int:value:"$vol" \
                -i "$icon" \
                -t 800 \
                "Volumen" "${vol}%" </dev/null >/dev/null 2>&1 &
fi
