#!/usr/bin/env bash

# Script to install Ghostty on Jetson (aarch64/arm64)
# Installs via snap and configures with specified settings

set -e  # Exit on any error

echo "Installing and configuring Ghostty on Jetson..."
echo ""

# Enable command tracing only for the main commands
set -x

# Install Ghostty via snap
sudo snap install ghostty --classic

# Disable command tracing
set +x

echo ""
echo "Ghostty installed successfully!"
echo ""

# Create config directory if it doesn't exist
CONFIG_DIR="$HOME/.config/ghostty"
CONFIG_FILE="$CONFIG_DIR/config"

mkdir -p "$CONFIG_DIR"

# Get absolute path for theme
THEME_PATH="$HOME/.local/share/nvim/lazy/tokyonight.nvim/extras/ghostty/tokyonight_night"

# Create or update config file
cat > "$CONFIG_FILE" << EOF
# Ghostty configuration
theme = $THEME_PATH
maximize = true
window-decoration = none
EOF

echo "Configuration written to $CONFIG_FILE"
echo ""

# Check if theme file exists and warn if not
if [ ! -f "$THEME_PATH" ]; then
    echo "WARNING: Theme file not found at: $THEME_PATH"
    echo "Make sure tokyonight.nvim is installed in your neovim setup."
    echo "If the path is different, edit the config file manually:"
    echo "  $CONFIG_FILE"
    echo ""
fi

echo "Ghostty configuration:"
echo "- Theme: $THEME_PATH"
echo "- Maximize: true"
echo "- Window decoration: none"
echo ""
echo "You can start Ghostty now or modify the config at: $CONFIG_FILE"
