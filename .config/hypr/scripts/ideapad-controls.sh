#!/usr/bin/env bash
# ==============================================================================
# Gestor y Selector de Utilidades Lenovo Ideapad para Waybar & Hyprland
# Equivalente a la extensión GNOME 'Ideapad Controls'
# ==============================================================================
set -euo pipefail

SYSFS_PATH="/sys/bus/platform/drivers/ideapad_acpi/VPC2004:00"
TOUCHPAD_DEVICE="syna2ba6:00-06cb:cd3e-touchpad"
TOUCHPAD_STATE_FILE="${HOME}/.cache/touchpad_state"

# Función para leer nodo sysfs
read_sysfs() {
    local node="$1"
    local path="${SYSFS_PATH}/${node}"
    if [ -f "$path" ]; then
        cat "$path" 2>/dev/null || echo "0"
    else
        echo "0"
    fi
}

# Función para escribir nodo sysfs con elevación segura
write_sysfs() {
    local node="$1"
    local val="$2"
    local path="${SYSFS_PATH}/${node}"

    if [ ! -f "$path" ]; then
        notify-send -u critical "Ideapad Controls" "El nodo $node no está disponible en este equipo."
        return 1
    fi

    if [ -w "$path" ]; then
        echo "$val" > "$path"
    elif command -v pkexec >/dev/null 2>&1; then
        pkexec sh -c "echo $val > '$path'"
    else
        sudo sh -c "echo $val > '$path'"
    fi
}

get_touchpad_status() {
    if [ -f "$TOUCHPAD_STATE_FILE" ]; then
        cat "$TOUCHPAD_STATE_FILE"
    else
        echo "1"
    fi
}

toggle_touchpad() {
    local cur
    cur=$(get_touchpad_status)
    if [ "$cur" = "1" ]; then
        hyprctl keyword "device[${TOUCHPAD_DEVICE}]:enabled" false >/dev/null 2>&1 || true
        echo "0" > "$TOUCHPAD_STATE_FILE"
        notify-send -h string:x-canonical-private-synchronous:ideapad-touchpad \
                    -i input-touchpad \
                    -t 1500 \
                    "Ideapad Controls" "Touchpad Desactivado"
    else
        hyprctl keyword "device[${TOUCHPAD_DEVICE}]:enabled" true >/dev/null 2>&1 || true
        echo "1" > "$TOUCHPAD_STATE_FILE"
        notify-send -h string:x-canonical-private-synchronous:ideapad-touchpad \
                    -i input-touchpad \
                    -t 1500 \
                    "Ideapad Controls" "Touchpad Activado"
    fi
    pkill -RTMIN+3 waybar 2>/dev/null || true
}

toggle_conservation() {
    local cur
    cur=$(read_sysfs "conservation_mode")
    if [ "$cur" = "1" ]; then
        write_sysfs "conservation_mode" "0"
        notify-send -h string:x-canonical-private-synchronous:ideapad-battery \
                    -i battery-full \
                    -t 1500 \
                    "Ideapad Controls" "Modo Conservación Desactivado (Carga al 100%)"
    else
        write_sysfs "conservation_mode" "1"
        notify-send -h string:x-canonical-private-synchronous:ideapad-battery \
                    -i battery-good \
                    -t 1500 \
                    "Ideapad Controls" "Modo Conservación Activado (Límite al 60%)"
    fi
    pkill -RTMIN+3 waybar 2>/dev/null || true
}

toggle_fn_lock() {
    local cur
    cur=$(read_sysfs "fn_lock")
    if [ "$cur" = "1" ]; then
        write_sysfs "fn_lock" "0"
        notify-send -h string:x-canonical-private-synchronous:ideapad-fn \
                    -i input-keyboard \
                    -t 1500 \
                    "Ideapad Controls" "Bloqueo Fn Desactivado (F1-F12 estándar)"
    else
        write_sysfs "fn_lock" "1"
        notify-send -h string:x-canonical-private-synchronous:ideapad-fn \
                    -i input-keyboard \
                    -t 1500 \
                    "Ideapad Controls" "Bloqueo Fn Activado (Funciones multimedia directas)"
    fi
    pkill -RTMIN+3 waybar 2>/dev/null || true
}

toggle_camera() {
    local cur
    cur=$(read_sysfs "camera_power")
    if [ "$cur" = "1" ]; then
        write_sysfs "camera_power" "0"
        notify-send -h string:x-canonical-private-synchronous:ideapad-camera \
                    -i camera-web \
                    -t 1500 \
                    "Ideapad Controls" "Cámara Web Desactivada (Privacidad)"
    else
        write_sysfs "camera_power" "1"
        notify-send -h string:x-canonical-private-synchronous:ideapad-camera \
                    -i camera-web \
                    -t 1500 \
                    "Ideapad Controls" "Cámara Web Activada"
    fi
    pkill -RTMIN+3 waybar 2>/dev/null || true
}

toggle_usb_charging() {
    local cur
    cur=$(read_sysfs "usb_charging")
    if [ "$cur" = "1" ]; then
        write_sysfs "usb_charging" "0"
        notify-send -h string:x-canonical-private-synchronous:ideapad-usb \
                    -i battery-charging \
                    -t 1500 \
                    "Ideapad Controls" "Carga USB con Equipo Apagado Desactivada"
    else
        write_sysfs "usb_charging" "1"
        notify-send -h string:x-canonical-private-synchronous:ideapad-usb \
                    -i battery-charging \
                    -t 1500 \
                    "Ideapad Controls" "Carga USB con Equipo Apagado Activada"
    fi
    pkill -RTMIN+3 waybar 2>/dev/null || true
}

menu() {
    local cons
    local fn
    local cam
    local usb
    local touch

    cons=$(read_sysfs "conservation_mode")
    fn=$(read_sysfs "fn_lock")
    cam=$(read_sysfs "camera_power")
    usb=$(read_sysfs "usb_charging")
    touch=$(get_touchpad_status)

    local options=""
    if [ "$cons" = "1" ]; then
        options+="󰂄 Modo Conservación Batería (Carga al 60%)  [ACTIVADO ✓]\n"
    else
        options+="󰂄 Modo Conservación Batería (Carga al 60%)  [DESACTIVADO]\n"
    fi

    if [ "$fn" = "1" ]; then
        options+="󰌌 Bloqueo de Teclas Fn (Fn Lock)  [ACTIVADO ✓]\n"
    else
        options+="󰌌 Bloqueo de Teclas Fn (Fn Lock)  [DESACTIVADO]\n"
    fi

    if [ "$cam" = "1" ]; then
        options+="󰄀 Cámara Web  [ACTIVADA ✓]\n"
    else
        options+="󰄀 Cámara Web  [DESACTIVADA]\n"
    fi

    if [ "$usb" = "1" ]; then
        options+="󱐋 Carga USB con Laptop Apagada  [ACTIVADA ✓]\n"
    else
        options+="󱐋 Carga USB con Laptop Apagada  [DESACTIVADA]\n"
    fi

    if [ "$touch" = "1" ]; then
        options+="󰍽 Touchpad  [ACTIVADO ✓]\n"
    else
        options+="󰍽 Touchpad  [DESACTIVADO]\n"
    fi

    local selected
    selected=$(echo -en "$options" | rofi -dmenu \
                                         -p "Lenovo Ideapad" \
                                         -l 6 \
                                         -i || true)

    if [ -z "$selected" ]; then
        exit 0
    fi

    case "$selected" in
        *"Conservación"*)
            toggle_conservation
            ;;
        *"Fn Lock"*)
            toggle_fn_lock
            ;;
        *"Cámara"*)
            toggle_camera
            ;;
        *"Carga USB"*)
            toggle_usb_charging
            ;;
        *"Touchpad"*)
            toggle_touchpad
            ;;
    esac
}

status_json() {
    local cons
    local fn
    local cam
    local usb
    local touch

    cons=$(read_sysfs "conservation_mode")
    fn=$(read_sysfs "fn_lock")
    cam=$(read_sysfs "camera_power")
    usb=$(read_sysfs "usb_charging")
    touch=$(get_touchpad_status)

    local cons_str=$([ "$cons" = "1" ] && echo "ON (60%)" || echo "OFF (100%)")
    local fn_str=$([ "$fn" = "1" ] && echo "ON" || echo "OFF")
    local cam_str=$([ "$cam" = "1" ] && echo "ON" || echo "OFF")
    local usb_str=$([ "$usb" = "1" ] && echo "ON" || echo "OFF")
    local touch_str=$([ "$touch" = "1" ] && echo "ON" || echo "OFF")

    local css_class="normal"
    if [ "$cons" = "1" ]; then
        css_class="conservation-on"
    fi

    local icon="󰌢"

    cat <<EOF
{"text": "$icon", "tooltip": "Ideapad Controls\n• Conservación: $cons_str\n• Bloqueo Fn: $fn_str\n• Cámara: $cam_str\n• Carga USB: $usb_str\n• Touchpad: $touch_str\n\nClic izquierdo: Menú completo\nClic derecho: Alternar Conservación", "class": "$css_class"}
EOF
}

case "${1:-}" in
    --status)
        status_json
        ;;
    --toggle-conservation)
        toggle_conservation
        ;;
    --toggle-fn-lock)
        toggle_fn_lock
        ;;
    --toggle-camera)
        toggle_camera
        ;;
    --toggle-usb-charging)
        toggle_usb_charging
        ;;
    --toggle-touchpad)
        toggle_touchpad
        ;;
    --menu|*)
        menu
        ;;
esac
