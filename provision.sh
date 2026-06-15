#!/bin/bash
# Provision: Configuración completa del sistema desde cero
# Uso: ./provision.sh [--packages] [--config] [--dev] [--projects] [--all]
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/lib/provision-helpers.sh"

GITHUB_USER="Santy401"

show_help() {
    cat <<EOF
Uso: ./provision.sh [FLAGS]

FLAGS:
  --packages         Instalar paquetes (pacman + AUR) y eliminar bloat
  --config           Clonar dotfiles + bootstrap symlinks
  --dev              Configurar entorno de desarrollo (mise, docker, npm)
  --projects         Clonar y restaurar proyectos
  --services         Habilitar servicios del sistema
  --all              Ejecutar todo (omite lo ya instalado)
  --help             Mostrar esta ayuda

Ejemplos:
  ./provision.sh --all
  ./provision.sh --packages --dev
EOF
}

DO_PACKAGES=false
DO_CONFIG=false
DO_DEV=false
DO_PROJECTS=false
DO_SERVICES=false

for arg in "$@"; do
    case "$arg" in
        --packages) DO_PACKAGES=true ;;
        --config)   DO_CONFIG=true ;;
        --dev)      DO_DEV=true ;;
        --projects) DO_PROJECTS=true ;;
        --services) DO_SERVICES=true ;;
        --all)      DO_PACKAGES=true; DO_CONFIG=true; DO_DEV=true; DO_PROJECTS=true; DO_SERVICES=true ;;
        --help|-h)  show_help; exit 0 ;;
        *)          err "Flag desconocido: $arg"; show_help; exit 1 ;;
    esac
done

if [[ $# -eq 0 ]]; then
    show_help
    exit 0
fi

require_sudo

# 1. PAQUETES
if $DO_PACKAGES; then
    section "1/5 — PAQUETES DEL SISTEMA"
    install_pacman "$SCRIPT_DIR/packages/custom-pacman.txt"
    install_aur "$SCRIPT_DIR/packages/aur.txt"
    remove_packages "$SCRIPT_DIR/packages/remove-bloat.txt"
    orphans=$(pacman -Qqtd 2>/dev/null || true)
    if [[ -n "$orphans" ]]; then
        sudo pacman -Rns --noconfirm $orphans 2>/dev/null || true
    fi
    add_user_groups docker libvirt wireshark
    ok "Paquetes OK"
fi

# 2. DOTFILES
if $DO_CONFIG; then
    section "2/5 — DOTFILES & CONFIGURACIÓN"
    if [[ ! -d "$HOME/github/Dotfiles" ]]; then
        git clone "https://github.com/$GITHUB_USER/Dotfiles.git" "$HOME/github/Dotfiles"
    fi
    if [[ -f "$HOME/github/Dotfiles/bootstrap.sh" ]]; then
        bash "$HOME/github/Dotfiles/bootstrap.sh"
    fi
    # JetBrains Mono Nerd Font
    if [[ ! -f "$HOME/.local/share/fonts/JetBrainsMonoNerdFont-Regular.ttf" ]]; then
        mkdir -p "$HOME/.local/share/fonts"
        wget -q "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/JetBrainsMono.zip" -O /tmp/jetbrains.zip
        unzip -q /tmp/jetbrains.zip -d "$HOME/.local/share/fonts/" 2>/dev/null || true
        fc-cache -f 2>/dev/null || true
        rm /tmp/jetbrains.zip
    fi
    ok "Configuración aplicada"
fi

# 3. ENTORNO DEV
if $DO_DEV; then
    section "3/5 — ENTORNO DE DESARROLLO"
    bash "$SCRIPT_DIR/provision/setup-dev.sh"
fi

# 4. PROYECTOS
if $DO_PROJECTS; then
    section "4/5 — PROYECTOS"
    bash "$SCRIPT_DIR/provision/restore-projects.sh"
fi

# 5. SERVICIOS
if $DO_SERVICES; then
    section "5/5 — SERVICIOS DEL SISTEMA"
    enable_services "$SCRIPT_DIR/packages/services-enable.txt"
    ok "Servicios habilitados"
fi

section "PROVISION COMPLETADO"
echo -e "  ${GREEN}✓${NC} Paquetes instalados"
echo -e "  ${GREEN}✓${NC} Configuración aplicada"
echo -e "  ${GREEN}✓${NC} Entorno dev listo"
echo -e "  ${GREEN}✓${NC} Proyectos restaurados"
echo ""
warn "Recomendado:"
echo "  1. Cierra sesión y vuelve a entrar (grupos docker/libvirt)"
echo "  2. Revisa los servicios con: systemctl --failed"
echo "  3. Si es primera vez: omarchy theme set <tu-thema>"
