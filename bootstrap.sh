#!/bin/bash
set -euo pipefail

DOTFILES="$HOME/github/Dotfiles"

echo "🔗 Symlinking dotfiles to $HOME..."

link() {
    src="$DOTFILES/$1"
    dest="$HOME/$1"
    mkdir -p "$(dirname "$dest")"
    if [ -e "$dest" ] && [ ! -L "$dest" ]; then
        mv "$dest" "$dest.bak.$(date +%s)"
        echo "  ↪ Backup creado: $dest.bak.$(date +%s)"
    fi
    ln -sfn "$src" "$dest"
    echo "  ✓ $dest → $src"
}

# Configs
link ".config/hypr/hyprland.conf"
link ".config/hypr/bindings.conf"
link ".config/hypr/monitors.conf"
link ".config/hypr/input.conf"
link ".config/hypr/looknfeel.conf"
link ".config/hypr/autostart.conf"
link ".config/hypr/hypridle.conf"
link ".config/hypr/hyprlock.conf"
link ".config/hypr/hyprsunset.conf"
link ".config/hypr/xdph.conf"
link ".config/waybar/config.jsonc"
link ".config/waybar/style.css"
link ".config/starship.toml"
link ".config/git/config"
link ".config/zed/settings.json"
link ".config/alacritty/alacritty.toml"
link ".config/tmux/tmux.conf"
link ".config/lazygit/config.yml"

echo "Recargando Configuracion"
hyprctl reload

echo "✅ Dotfiles instalados. Recarga tu shell: exec bash"
