#!/usr/bin/env bash
# ==============================================================================
# Script de Instalación / Restauración del Setup de Inkscape + Emacs Math Pad
# ==============================================================================
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> 1. Instalando extensiones y atajos de Inkscape..."
mkdir -p "$HOME/.config/inkscape/extensions"
mkdir -p "$HOME/.config/inkscape/keys"
cp -r "$SCRIPT_DIR/extensions/"* "$HOME/.config/inkscape/extensions/"
cp "$SCRIPT_DIR/keys/default.xml" "$HOME/.config/inkscape/keys/default.xml"

echo "==> 2. Instalando scripts ejecutables en ~/.local/bin/..."
mkdir -p "$HOME/.local/bin"
cp "$SCRIPT_DIR/bin/inkscape-math-pad" "$HOME/.local/bin/inkscape-math-pad"
cp "$SCRIPT_DIR/bin/wayland-paste" "$HOME/.local/bin/wayland-paste"
chmod +x "$HOME/.local/bin/inkscape-math-pad"
chmod +x "$HOME/.local/bin/wayland-paste"

echo "==> 3. Instalando lanzador de aplicación de escritorio..."
mkdir -p "$HOME/.local/share/applications"
cp "$SCRIPT_DIR/applications/inkscape-math-pad.desktop" "$HOME/.local/share/applications/inkscape-math-pad.desktop"
chmod +x "$HOME/.local/share/applications/inkscape-math-pad.desktop"
update-desktop-database "$HOME/.local/share/applications" 2>/dev/null || true

echo "==> 4. Configurando y arrancando servicio systemd del demonio de pegado..."
mkdir -p "$HOME/.config/systemd/user"
cp "$SCRIPT_DIR/systemd/wayland-paste.service" "$HOME/.config/systemd/user/wayland-paste.service"
systemctl --user daemon-reload
systemctl --user enable --now wayland-paste.service

echo "==> 5. Configurando atajo de teclado en GNOME (<Alt>m)..."
KB_PATH="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/inkscape-math-pad/"
EXISTING=$(gsettings get org.gnome.settings-daemon.plugins.media-keys custom-keybindings)

if [[ "$EXISTING" != *"$KB_PATH"* ]]; then
    if [ "$EXISTING" = "@as []" ] || [ "$EXISTING" = "[]" ]; then
        NEW_LIST="['$KB_PATH']"
    else
        NEW_LIST="${EXISTING%]*}, '$KB_PATH']"
    fi
    gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "$NEW_LIST" 2>/dev/null || true
fi

gsettings set "org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$KB_PATH" name "Emacs Math Pad para Inkscape" 2>/dev/null || true
gsettings set "org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$KB_PATH" command "$HOME/.local/bin/inkscape-math-pad" 2>/dev/null || true
gsettings set "org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$KB_PATH" binding "<Alt>m" 2>/dev/null || true

echo ""
echo "✅ Instalación y sincronización completada con éxito."
