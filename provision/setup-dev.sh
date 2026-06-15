#!/bin/bash
# Provision: Entorno de desarrollo
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/lib/provision-helpers.sh"

section "ENTORNO DE DESARROLLO"

# --- mise (runtime manager) ---
if ! command -v mise &>/dev/null; then
    info "Instalando mise..."
    curl https://mise.jdx.dev/install.sh | sh
    eval "$(mise activate bash)"
else
    ok "mise ya instalado"
fi

# Runtimes via mise
info "Instalando runtimes con mise..."
mise use --global node@latest python@latest 2>/dev/null || true
mise install 2>/dev/null || true
ok "Runtimes instalados"

# --- Docker ---
if ! getent group docker | grep -q "$USER"; then
    info "Agregando usuario al grupo docker..."
    sudo usermod -aG docker "$USER"
    sudo systemctl enable --now docker.service
    warn "Cierra sesión y vuelve a entrar para usar docker sin sudo"
else
    ok "Docker configurado"
fi

# --- npm global tools ---
if command -v npm &>/dev/null; then
    info "Instalando herramientas npm globales..."
    npm install -g pnpm@latest 2>/dev/null || true
    # npm install -g typescript @angular/cli 2>/dev/null || true
    ok "Herramientas npm instaladas"
fi

# --- dotnet (si se necesita) ---
# if command -v dotnet &>/dev/null; then
#     info "Actualizando dotnet workloads..."
#     dotnet workload update 2>/dev/null || true
# fi

# --- Proyectos locales ---
mkdir -p "$HOME/github"

ok "Entorno de desarrollo listo"
