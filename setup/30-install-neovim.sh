#!/usr/bin/env bash

# Script to install latest stable Neovim on Jetson device
# Uses AppImage for ARM64 compatibility and installs to ~/.local/bin

set -e  # Exit on any error
# set -x will be enabled only for actual commands, not echo statements

echo "Installing latest stable Neovim on Jetson device..."
echo "This will download the ARM64 AppImage and install it to ~/.local/bin"
echo ""
echo "Solution based on: https://github.com/neovim/neovim/blob/master/INSTALL.md"
echo ""

# Ask about nvim config repository
echo "Neovim Configuration Setup (optional):"
echo "If you have a Git repository with your Neovim configuration, it can be cloned to ~/.config/nvim"
read -p "Do you have a Neovim config repository? (y/N): " HAS_CONFIG

if [[ "$HAS_CONFIG" =~ ^[Yy]$ ]]; then
    echo ""
    echo "Please provide your Neovim config repository URL:"
    echo "Examples:"
    echo "  - SSH: git@github.com:username/nvim-config.git"
    echo "  - HTTPS: https://github.com/username/nvim-config.git"
    read -p "Repository URL: " CONFIG_REPO_URL
    echo ""
fi

echo "Starting Neovim installation..."
echo "Using AppImage for ARM64 compatibility and easier management."
echo ""

# Enable command tracing only for the main commands
set -x

# Create ~/.local/bin directory if it doesn't exist
mkdir -p ~/.local/bin

# Download latest stable Neovim ARM64 AppImage
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-arm64.appimage

# Make it executable
chmod u+x nvim-linux-arm64.appimage

# Move to ~/.local/bin with a clean name
mv nvim-linux-arm64.appimage ~/.local/bin/nvim

# Clone nvim config if provided
if [[ "$HAS_CONFIG" =~ ^[Yy]$ ]] && [[ -n "$CONFIG_REPO_URL" ]]; then
    # Remove existing config if it exists
    if [ -d ~/.config/nvim ]; then
        echo "Backing up existing nvim config to ~/.config/nvim.backup.$(date +%Y%m%d_%H%M%S)"
        mv ~/.config/nvim ~/.config/nvim.backup.$(date +%Y%m%d_%H%M%S)
    fi
    
    # Clone the config repository
    git clone "$CONFIG_REPO_URL" ~/.config/nvim
    
    # Try to install plugins automatically
    echo ""
    echo "Attempting to install plugins..."
    
    # Check if lazy.nvim is used (most common)
    if [ -f ~/.config/nvim/lua/lazy-bootstrap.lua ] || grep -r "lazy.nvim" ~/.config/nvim/ >/dev/null 2>&1; then
        echo "Detected lazy.nvim plugin manager"
        ~/.local/bin/nvim --headless "+Lazy! sync" +qa
    # Check if packer.nvim is used
    elif [ -f ~/.config/nvim/lua/plugins.lua ] || grep -r "packer" ~/.config/nvim/ >/dev/null 2>&1; then
        echo "Detected packer.nvim plugin manager"
        ~/.local/bin/nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync'
    # Check if vim-plug is used
    elif grep -r "plug#begin\|Plug " ~/.config/nvim/ >/dev/null 2>&1; then
        echo "Detected vim-plug plugin manager"
        ~/.local/bin/nvim --headless +PlugInstall +qall
    # Check if paq-nvim is used
    elif grep -r "paq" ~/.config/nvim/ >/dev/null 2>&1; then
        echo "Detected paq-nvim plugin manager"
        ~/.local/bin/nvim --headless -c 'lua require("paq"):sync()' +qa
    else
        echo "No recognized plugin manager found, or plugins may auto-install on first run"
        echo "Common plugin managers: lazy.nvim, packer.nvim, vim-plug, paq-nvim"
    fi
fi

# Disable command tracing
set +x

echo ""
echo "Successfully installed Neovim!"
echo ""
echo "Installation details:"
echo "  AppImage: ~/.local/bin/nvim"
echo "  Type: ARM64 AppImage (self-contained)"
echo ""
echo "Neovim version:"
~/.local/bin/nvim --version | head -n 1
echo ""

# Check if ~/.local/bin is in PATH
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    echo "IMPORTANT: ~/.local/bin is not in your PATH."
    echo "Add this to your shell configuration file (~/.bashrc, ~/.zshrc, etc.):"
    echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""
    echo ""
    echo "Then reload your shell or run: source ~/.bashrc"
    echo ""
    echo "For now, you can run Neovim with: ~/.local/bin/nvim"
else
    echo "✓ ~/.local/bin is already in your PATH"
    echo "You can run Neovim with: nvim"
fi

if [[ "$HAS_CONFIG" =~ ^[Yy]$ ]] && [[ -n "$CONFIG_REPO_URL" ]]; then
    echo ""
    echo "✓ Neovim configuration cloned to ~/.config/nvim"
    echo "✓ Attempted automatic plugin installation"
    echo ""
    echo "Note: Some plugins may require additional setup or may install on first nvim run."
    echo "If plugins didn't install automatically, try running nvim and executing:"
    echo "  - For lazy.nvim: :Lazy sync"
    echo "  - For packer.nvim: :PackerSync" 
    echo "  - For vim-plug: :PlugInstall"
    echo "  - For paq-nvim: :lua require('paq'):sync()"
fi

echo ""
echo "AppImage advantages for Jetson:"
echo "  ✓ ARM64 native binary"
echo "  ✓ Self-contained (no dependency issues)"
echo "  ✓ Easy updates (just download new AppImage)"
echo "  ✓ No glibc version conflicts"
echo ""
echo "To update Neovim in the future, just run this script again!"
echo "Neovim is ready to use!"
