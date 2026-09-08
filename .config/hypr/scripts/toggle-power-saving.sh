#!/usr/bin/env bash
# Script para alternar en caliente el Modo Ahorro de Energía en Hyprland (Pantalla 4K)

STATUS=$(hyprctl getoption decoration:blur:enabled | awk 'NR==1{print $2}')

if [ "$STATUS" = "1" ]; then
    # Desactivar efectos intensivos en GPU
    hyprctl keyword decoration:blur:enabled false
    hyprctl keyword decoration:shadow:enabled false
    hyprctl keyword animations:enabled false
    notify-send -t 2000 -u low "Modo Batería" "Efectos gráficos y blur desactivados"
else
    # Reactivar efectos completos
    hyprctl keyword decoration:blur:enabled true
    hyprctl keyword decoration:shadow:enabled true
    hyprctl keyword animations:enabled true
    notify-send -t 2000 -u low "Modo Estético" "Efectos visuales completos activados"
fi
