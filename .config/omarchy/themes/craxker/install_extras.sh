#!/bin/bash

# install_extras.sh - Install Craxker theme and fastfetch configuration

# Exit on any error
set -e

# Get current timestamp for backup
TIMESTAMP=$(date +"%Y%m%d-%H%M%S")

echo "Starting installation of extras..."

# Create .themes directory if it doesn't exist
mkdir -p "$HOME/.themes"

# Copy Craxker theme to .themes directory
if [ -d "Craxker" ]; then
    echo "Copying Craxker theme to ~/.themes..."
    cp -r Craxker "$HOME/.themes/"
    echo "Craxker theme installed successfully."
else
    echo "Warning: Craxker directory not found in current directory."
fi

# Create .config directory if it doesn't exist
mkdir -p "$HOME/.config"

# Backup existing fastfetch configuration if it exists
if [ -d "$HOME/.config/fastfetch" ]; then
    echo "Backing up existing fastfetch configuration..."
    mv "$HOME/.config/fastfetch" "$HOME/.config/fastfetch-$TIMESTAMP"
    echo "Backup created: ~/.config/fastfetch-$TIMESTAMP"
fi

# Copy fastfetch configuration to .config directory
if [ -d "fastfetch" ]; then
    echo "Copying fastfetch configuration to ~/.config..."
    cp -r fastfetch "$HOME/.config/"
    echo "fastfetch configuration installed successfully."
else
    echo "Warning: fastfetch directory not found in current directory."
fi

echo "Installation completed successfully!"
echo "Summary:"
echo "- Craxker theme: ~/.themes/Craxker"
echo "- fastfetch config: ~/.config/fastfetch"
if [ -d "$HOME/.config/fastfetch-$TIMESTAMP" ]; then
    echo "- fastfetch backup: ~/.config/fastfetch-$TIMESTAMP"
fi
