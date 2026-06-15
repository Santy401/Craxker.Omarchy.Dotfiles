# Arch.Dotfiles

Configuración personal de Santy401 para Omarchy/Arch Linux + Hyprland.

## Estructura

```
.config/
├── hypr/          # Hyprland (WM)
├── waybar/        # Status bar
├── git/config     # Git global
├── starship.toml  # Prompt
├── zed/           # Editor
├── lazygit/       # Git TUI
└── tmux/          # Terminal multiplexer
├── bootstrap.sh       # Symlinks de ~/.config/ → dotfiles
├── provision.sh       # Script principal de provisioning
├── provision/         # Módulos del provision
│   ├── setup-dev.sh       # Entorno dev (mise, docker, npm)
│   └── restore-projects.sh # Clonar proyectos
├── packages/            # Listas de paquetes
│   ├── custom-pacman.txt
│   ├── aur.txt
│   ├── remove-bloat.txt
│   └── services-enable.txt
└── lib/
    └── provision-helpers.sh

## Uso

```bash
# Después de instalar Omarchy fresh:
git clone https://github.com/Santy401/Arch.Dotfiles.git ~/github/Dotfiles
cd ~/github/Dotfiles

# Instalar todo
./provision.sh --all

# O por partes:
./provision.sh --packages   # Solo paquetes
./provision.sh --config     # Solo symlinks
./provision.sh --dev        # Solo entorno dev
./provision.sh --projects   # Solo proyectos
./provision.sh --services   # Solo servicios
```
