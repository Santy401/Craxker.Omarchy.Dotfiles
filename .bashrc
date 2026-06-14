# If not running interactively, don't do anything (leave this at the top of this file)
[[ $- != *i* ]] && return

# All the default Omarchy aliases and functions
# (don't mess with these directly, just overwrite them here!)
source ~/.local/share/omarchy/default/bash/rc

# Add your own exports, aliases, and functions here.
eval "$(thefuck --alias)"
alias mouse="/home/developer/github/g203-controller/scripts/g203-tui.py"

. "$HOME/.local/share/../bin/env"


# Added by Antigravity CLI installer
export PATH="/home/developer/.local/bin:$PATH"

alias developer="ssh developer@192.168.1.9"

# Comands Install
alias i="sudo pacman -S"
alias yi="yay -S"

# WorkDirectories And Up Servers
alias s="cd ~/github/SimplappV2 && pnpm dev"
alias o="cd ~/github/opticapp.com && docker-compose up"
