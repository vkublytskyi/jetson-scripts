#!/usr/bin/env bash

# Script to install NVM and latest stable Node.js on Jetson device
# Solution based on: https://github.com/nvm-sh/nvm

set -e  # Exit on any error
# set -x will be enabled only for actual commands, not echo statements

echo "Installing NVM (Node Version Manager) and latest stable Node.js..."
echo "This will install NVM and use it to install the latest stable Node.js version."
echo ""
echo "Note: NVM is a shell function (not a binary) and must be installed to ~/.nvm"
echo "It works by sourcing shell scripts to modify environment variables."
echo ""
echo "Solution based on: https://github.com/nvm-sh/nvm"
echo ""

# Check for existing Node.js installation
if command -v node >/dev/null 2>&1; then
    echo "Existing Node.js installation detected:"
    echo "  Version: $(node --version)"
    echo "  Location: $(which node)"
    echo ""
    echo "NVM will install and manage separate Node.js versions."
    echo "You can choose which version to use with 'nvm use <version>'"
    echo ""
fi

# Check if NVM is already installed
if [ -s "$HOME/.nvm/nvm.sh" ]; then
    echo "NVM is already installed at ~/.nvm"
    # Try to source NVM to check version
    source "$HOME/.nvm/nvm.sh" 2>/dev/null || true
    if command -v nvm >/dev/null 2>&1; then
        echo "Current NVM version: $(nvm --version)"
    fi
    echo ""
    read -p "Do you want to reinstall NVM? (y/N): " REINSTALL_NVM
    if [[ ! "$REINSTALL_NVM" =~ ^[Yy]$ ]]; then
        echo "Skipping NVM installation..."
        NVM_ALREADY_INSTALLED=true
    else
        NVM_ALREADY_INSTALLED=false
    fi
else
    NVM_ALREADY_INSTALLED=false
fi

echo "Starting installation process..."
echo ""

# Enable command tracing only for the main commands
set -x

if [ "$NVM_ALREADY_INSTALLED" = false ]; then
    # Install NVM using the official installer script
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
    
    # Source NVM to make it available in current session
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
else
    # NVM already installed, just source it
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
fi

# Install latest stable Node.js version
nvm install node

# Set the latest stable version as default
nvm use node
nvm alias default node

# Disable command tracing
set +x

echo ""
echo "Successfully installed NVM and Node.js!"
echo ""

# Source NVM again to ensure it's available for status display
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

echo "Installation details:"
echo "  NVM location: ~/.nvm"
echo "  NVM version: $(nvm --version 2>/dev/null || echo "NVM not yet available in this session")"

if command -v node >/dev/null 2>&1; then
    echo "  Node.js version: $(node --version)"
    echo "  Node.js location: $(which node)"
    echo "  npm version: $(npm --version)"
fi

echo ""
echo "✓ Latest stable Node.js installed via NVM and set as default"
echo "✓ NVM configuration added to ~/.bashrc"
echo ""

# Show installed Node versions if NVM is available
if command -v nvm >/dev/null 2>&1; then
    echo "Installed Node.js versions:"
    nvm list
else
    echo "Note: NVM is not yet available in this session."
fi

echo ""
echo "NVM is now ready to use!"
echo ""
echo "IMPORTANT: To use NVM in this terminal session, run:"
echo "  source ~/.bashrc"
echo ""
echo "Or restart your terminal to automatically load NVM."
echo ""
echo "NVM is now ready to use!"
echo ""
echo "Common NVM commands:"
echo "  nvm list                    # List installed Node versions"
echo "  nvm install <version>       # Install specific Node version"
echo "  nvm use <version>          # Switch to specific Node version"
echo "  nvm alias default <version> # Set default Node version"
echo "  nvm current                # Show current Node version"
echo ""
echo "Node.js and npm are now available:"
echo "  node --version"
echo "  npm --version"
echo ""
echo "To use NVM in new terminal sessions, restart your terminal or run:"
echo "  source ~/.bashrc"
