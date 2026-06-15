# If not running interactively, don't do anything (leave this at the top of this file)
[[ $- != *i* ]] && return

fastfetch

# All the default Omarchy aliases and functions
# (don't mess with these directly, just overwrite them here!)
source ~/.local/share/omarchy/default/bash/rc

# Add your own exports, aliases, and functions here.
eval "$(thefuck --alias)"
alias mouse="/home/developer/github/g203-controller/scripts/g203-tui.py"

. "$HOME/.local/share/../bin/env"z


# Added by Antigravity CLI installer
export PATH="/home/developer/.local/bin:$PATH"

alias developer="ssh developer@192.168.1.9"

# Minikube and Kubectl
alias mk="minikube"
alias k="kubectl"

# Comands Install
alias i="sudo pacman -S"
alias y="yay -S"

# Dev Aliases
alias simplapp="cd ~/github/SimplappV2 && pnpm dev"
alias dotfiles="cd ~/github/Dotfiles"
alias museopozon="cd ~/github/CasaMuseoPozon"

# Tmux sessions
alias tx="tmux attach -t"
alias tx-simplapp="tmux attach -t simplapp"
alias tx-ls="tmux list-sessions"

# Journal
alias daily="cd ~/Documents/Obsidian\ Vault && nvim Daily/$(date +%Y-%m-%d).md"
