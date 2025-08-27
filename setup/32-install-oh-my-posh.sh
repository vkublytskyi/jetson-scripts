#!/usr/bin/env bash

# Script to install Oh My Posh on Jetson device
# Solution based on: https://ohmyposh.dev/docs/installation/linux

set -e  # Exit on any error
# set -x will be enabled only for actual commands, not echo statements

echo "Installing Oh My Posh on Jetson device..."
echo "This will install Oh My Posh and configure it for bash."
echo ""
echo "Solution based on: https://ohmyposh.dev/docs/installation/linux"
echo ""

# Ask about custom themes repository
echo "Theme Configuration:"
read -p "Do you have a Git repository with custom themes? (y/N): " HAS_THEMES_REPO

THEMES_REPO_URL=""
if [[ "$HAS_THEMES_REPO" =~ ^[Yy]$ ]]; then
    echo ""
    echo "Please provide your themes repository URL:"
    echo "Examples:"
    echo "  - SSH: git@github.com:username/my-omp-themes.git"
    echo "  - HTTPS: https://github.com/username/my-omp-themes.git"
    read -p "Repository URL: " THEMES_REPO_URL
    echo ""
fi

# Ask about theme selection
echo "Theme Selection:"
echo "Enter the theme name you want to use (without .omp.json extension)"
echo "Examples: jandedobbeleer, paradox, atomic, powerline"
echo "Leave empty to configure Oh My Posh without a specific theme"
read -p "Theme name (optional): " THEME_NAME

echo ""
echo "Starting Oh My Posh installation..."
echo ""

# Enable command tracing only for the main commands
set -x

# Install Oh My Posh using the official installer script
curl -s https://ohmyposh.dev/install.sh | bash -s -- -d ~/.local/bin

# Clone custom themes repository if provided
if [[ "$HAS_THEMES_REPO" =~ ^[Yy]$ ]] && [[ -n "$THEMES_REPO_URL" ]]; then
    # Remove existing themes directory if it exists
    rm -rf $HOME/.config/oh-my-posh
    # Clone themes repository
    git clone "$THEMES_REPO_URL" $HOME/.config/oh-my-posh
fi

# Disable command tracing for config logic
set +x

# Determine config path based on theme selection
CONFIG_PATH=""
CONFIG_SOURCE=""

if [[ -n "$THEME_NAME" ]]; then
    # Check if custom theme exists in local repo
    if [[ -f $HOME/.config/oh-my-posh/themes/${THEME_NAME}.omp.json ]]; then
        CONFIG_PATH="$HOME/.config/oh-my-posh/themes/${THEME_NAME}.omp.json"
        CONFIG_SOURCE="custom repository"
    else
        # Check if official theme exists (we'll verify this when adding to .bashrc)
        OFFICIAL_THEME_URL="https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/${THEME_NAME}.omp.json"
        
        # Test if the URL exists
        if curl --output /dev/null --silent --head --fail "$OFFICIAL_THEME_URL"; then
            CONFIG_PATH="$OFFICIAL_THEME_URL"
            CONFIG_SOURCE="official repository"
        else
            CONFIG_PATH=""
            CONFIG_SOURCE="not found"
        fi
    fi
fi

# Enable command tracing for bashrc modification
set -x

# Backup existing .bashrc
cp ~/.bashrc $HOME/.bashrc.backup.$(date +%Y%m%d_%H%M%S)

# Remove any existing Oh My Posh configuration from .bashrc
sed -i '/oh-my-posh/d' $HOME/.bashrc

# Add Oh My Posh initialization to .bashrc
echo "" >> ~/.bashrc
echo "# Oh My Posh configuration" >> ~/.bashrc

if [[ -n "$CONFIG_PATH" ]]; then
    echo "eval \"\$($HOME/.local/bin/oh-my-posh init bash --config $CONFIG_PATH)\"" >> $HOME/.bashrc
else
    echo "eval \"\$($HOME/.local/bin/oh-my-posh init bash)\"" >> $HOME/.bashrc
fi

# Disable command tracing
set +x

echo ""
echo "Successfully installed Oh My Posh!"
echo ""
echo "Installation details:"
echo "  Binary: ~/.local/bin/oh-my-posh"

if [[ "$HAS_THEMES_REPO" =~ ^[Yy]$ ]] && [[ -n "$THEMES_REPO_URL" ]]; then
    echo "  Custom themes: ~/.config/oh-my-posh/"
fi

echo ""
echo "Configuration:"
if [[ -n "$THEME_NAME" ]]; then
    if [[ -n "$CONFIG_PATH" ]]; then
        echo "  ✓ Theme: $THEME_NAME (from $CONFIG_SOURCE)"
        echo "  ✓ Config: $CONFIG_PATH"
    else
        echo "  ⚠️  Theme '$THEME_NAME' not found!"
        echo "  ℹ️  Configured Oh My Posh without theme"
        echo ""
        echo "To configure a theme manually:"
        echo "  1. Edit ~/.bashrc"
        echo "  2. Update the oh-my-posh init line with --config flag:"
        echo "     eval \"\$(oh-my-posh init bash --config /path/to/theme.omp.json)\""
        echo ""
        echo "Available official themes: https://ohmyposh.dev/docs/themes"
    fi
else
    echo "  ✓ Configured without specific theme (as requested)"
    echo ""
    echo "To add a theme later:"
    echo "  1. Edit ~/.bashrc"
    echo "  2. Add --config flag to oh-my-posh init line:"
    echo "     eval \"\$(oh-my-posh init bash --config /path/to/theme.omp.json)\""
fi

echo ""
echo "✓ Added Oh My Posh initialization to ~/.bashrc"
echo "✓ Backed up original .bashrc to ~/.bashrc.backup.$(date +%Y%m%d_%H%M%S)"
echo ""
echo "To activate Oh My Posh:"
echo "  1. Restart your terminal session, OR"
echo "  2. Run: source ~/.bashrc"
echo ""
echo "Note: You may want to install a Nerd Font for the best experience:"
echo "  https://www.nerdfonts.com/font-downloads"
