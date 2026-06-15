# shellcheck shell=bash
# Provision Helpers — funciones compartidas para el setup

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

info()  { echo -e "${CYAN}[INFO]${NC}  $1"; }
ok()    { echo -e "${GREEN}[OK]${NC}    $1"; }
warn()  { echo -e "${YELLOW}[WARN]${NC}  $1"; }
err()   { echo -e "${RED}[ERR]${NC}   $1"; }

section() {
    echo ""
    echo -e "${CYAN}══════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  $1${NC}"
    echo -e "${CYAN}══════════════════════════════════════════════${NC}"
    echo ""
}

require_sudo() {
    if [[ $EUID -eq 0 ]]; then
        err "No ejecutar como root. Ejecuta como usuario normal."
        exit 1
    fi
    if ! sudo -v &>/dev/null; then
        err "Este script necesita sudo."
        exit 1
    fi
}

install_pacman() {
    local file="$1"
    if [[ ! -f "$file" ]]; then
        warn "Archivo no encontrado: $file"
        return
    fi
    info "Instalando paquetes pacman desde $file..."
    sudo pacman -S --needed --noconfirm - < "$file" 2>/dev/null || \
    xargs -a "$file" sudo pacman -S --needed --noconfirm
    ok "Paquetes pacman instalados."
}

install_aur() {
    local file="$1"
    if [[ ! -f "$file" ]]; then
        warn "Archivo no encontrado: $file"
        return
    fi
    if ! command -v yay &>/dev/null; then
        info "Instalando yay (AUR helper)..."
        sudo pacman -S --needed --noconfirm base-devel git
        git clone https://aur.archlinux.org/yay.git /tmp/yay
        (cd /tmp/yay && makepkg -si --noconfirm)
        rm -rf /tmp/yay
    fi
    info "Instalando paquetes AUR..."
    xargs -a "$file" yay -S --needed --noconfirm
    ok "Paquetes AUR instalados."
}

remove_packages() {
    local file="$1"
    if [[ ! -f "$file" ]]; then
        return
    fi
    # Filtrar solo paquetes realmente instalados
    local to_remove=()
    while IFS= read -r pkg; do
        [[ -z "$pkg" || "$pkg" =~ ^# ]] && continue
        if pacman -Q "$pkg" &>/dev/null; then
            to_remove+=("$pkg")
        fi
    done < "$file"
    if [[ ${#to_remove[@]} -gt 0 ]]; then
        info "Eliminando paquetes no deseados: ${to_remove[*]}"
        sudo pacman -Rns --noconfirm "${to_remove[@]}"
        ok "Paquetes eliminados."
    fi
}

enable_services() {
    local file="$1"
    if [[ ! -f "$file" ]]; then
        return
    fi
    while IFS= read -r svc; do
        [[ -z "$svc" || "$svc" =~ ^# ]] && continue
        sudo systemctl enable --now "$svc" 2>/dev/null && ok "$svc enabled" || warn "No se pudo habilitar $svc"
    done < "$file"
}

add_user_groups() {
    for group in "$@"; do
        if getent group "$group" &>/dev/null; then
            sudo usermod -aG "$group" "$USER"
            ok "Usuario agregado al grupo $group"
        fi
    done
}
