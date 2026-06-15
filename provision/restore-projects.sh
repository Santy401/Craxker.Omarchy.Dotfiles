#!/bin/bash
# Provision: Restaurar proyectos desde GitHub
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/lib/provision-helpers.sh"

section "RESTAURAR PROYECTOS"

GITHUB_USER="Santy401"
GITHUB_DIR="$HOME/github"

mkdir -p "$GITHUB_DIR"

clone_or_pull() {
    local repo="$1"
    local target="$GITHUB_DIR/$repo"
    if [[ -d "$target/.git" ]]; then
        info "Actualizando $repo..."
        git -C "$target" pull --rebase 2>/dev/null || true
        ok "$repo actualizado"
    else
        info "Clonando $repo..."
        git clone "https://github.com/$GITHUB_USER/$repo.git" "$target" 2>/dev/null || {
            warn "No se pudo clonar $repo (puede ser privado)"
            return
        }
        ok "$repo clonado"
    fi
}

# --- Proyectos principales ---
# clone_or_pull "Dotfiles"
clone_or_pull "SimplappV2"
# clone_or_pull "opticapp.com"
clone_or_pull "CasaMuseoPozon"
clone_or_pull "g203-controller"
# clone_or_pull "AttackVM"

# --- Si existe token gh, intentar clonar privados ---
if command -v gh &>/dev/null && gh auth status &>/dev/null 2>&1; then
    info "GitHub CLI autenticado. Clonando repos privados..."
    # gh repo clone Santy401/opticapp.com "$GITHUB_DIR/opticapp.com" 2>/dev/null || true
fi

# --- Instalar dependencias de proyectos que lo requieran ---
if [[ -d "$GITHUB_DIR/SimplappV2" ]]; then
    info "Instalando dependencias de SimplappV2..."
    cd "$GITHUB_DIR/SimplappV2"
    if command -v pnpm &>/dev/null; then
        pnpm install 2>/dev/null || warn "pnpm install falló"
    fi
fi

if [[ -d "$GITHUB_DIR/opticapp.com" ]]; then
    info "Instalando dependencias de opticapp.com..."
    cd "$GITHUB_DIR/opticapp.com"
    if command -v composer &>/dev/null; then
        composer install 2>/dev/null || warn "composer install falló"
    fi
    if command -v npm &>/dev/null; then
        npm install 2>/dev/null || warn "npm install falló"
    fi
fi

ok "Proyectos restaurados"
