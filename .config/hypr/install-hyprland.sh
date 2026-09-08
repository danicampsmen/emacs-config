#!/usr/bin/env bash
set -euo pipefail

echo "=== Ecosistema completo Hyprland para Lenovo Yoga 9 (Ubuntu 26.04) ==="

if ! command -v apt >/dev/null 2>&1; then
  echo "Este script requiere apt. Abortando."
  exit 1
fi

sudo apt update
sudo apt install -y \
  hyprland xdg-desktop-portal-hyprland hyprpolkitagent \
  hyprpaper hyprlock hypridle \
  mako-notifier cliphist \
  thunar udiskie tumbler ffmpegthumbnailer \
  wlsunset wlogout wf-recorder \
  waybar kitty zathura zathura-pdf-poppler \
  wofi grim slurp wl-clipboard \
  brightnessctl pamixer pavucontrol blueman \
  fonts-noto-core fonts-noto-color-emoji

# Activar huella dactilar para hyprlock si fprintd está presente
if [ -f /etc/pam.d/hyprlock ] && ! grep -q "pam_fprintd.so" /etc/pam.d/hyprlock; then
  sudo sed -i '1i auth sufficient pam_fprintd.so' /etc/pam.d/hyprlock
fi

echo "=== Instalación completa ==="
echo "Cierra sesión y elige 'Hyprland' en la pantalla de GDM."
