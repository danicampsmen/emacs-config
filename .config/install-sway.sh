#!/usr/bin/env bash
set -euo pipefail

echo "=== Sway ecosystem installer ==="

if ! command -v apt >/dev/null 2>&1; then
  echo "This script requires apt. Aborting."
  exit 1
fi

sudo apt update
sudo apt install -y \
  sway swaylock swayidle \
  waybar kitty zathura zathura-pdf-poppler \
  wofi grim slurp wl-clipboard \
  brightnessctl pamixer \
  pavucontrol blueman \
  fonts-noto-core fonts-noto-color-emoji \
  python3 python3-pip

echo "=== Symlinks ==="
mkdir -p ~/.config/sway ~/.config/kitty ~/.config/waybar ~/.config/zathura
ln -sf ~/.emacs.d/.config/kitty/kitty.conf ~/.config/kitty/kitty.conf
ln -sf ~/.emacs.d/.config/waybar/config ~/.config/waybar/config
ln -sf ~/.emacs.d/.config/zathura/zathurarc ~/.config/zathura/zathurarc

echo "=== Done ==="
echo "Log out and choose 'Sway' at the display manager, or run 'sway' from a TTY."
