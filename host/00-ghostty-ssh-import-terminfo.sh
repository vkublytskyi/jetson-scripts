#!/usr/bin/env bash

# Script to install Ghostty terminfo on remote host
# Solution based on: https://ghostty.org/docs/help/terminfo

set -e  # Exit on any error
# set -x will be enabled only for actual commands, not echo statements

# Check if JETSON_HOST environment variable is set
if [ -z "$JETSON_HOST" ]; then
    echo "Error: JETSON_HOST environment variable is not set."
    echo ""
    echo "Please set the JETSON_HOST variable to your remote host address."
    echo ""
    echo "To find your Jetson device IP address (JetPack/Ubuntu), run these commands ON THE JETSON:"
    echo "  # Show all network interfaces:"
    echo "  ip addr show"
    echo "  # Or for just the active IP addresses:"
    echo "  hostname -I"
    echo "  # Or using ifconfig (if installed):"
    echo "  ifconfig"
    echo ""
    echo "Look for:"
    echo "  - eth0 (Ethernet) - typically 192.168.x.x or 10.x.x.x"
    echo "  - wlan0 (WiFi) - typically 192.168.x.x"
    echo "  - Ignore 127.0.0.1 (localhost) and docker interfaces"
    echo ""
    echo "You can set it temporarily with:"
    echo "  export JETSON_HOST=your-jetson-ip-address"
    echo ""
    echo "Or add it to your shell configuration file permanently:"
    echo "  # For bash users - add to ~/.bashrc:"
    echo "  echo 'export JETSON_HOST=your-jetson-ip-address' >> ~/.bashrc"
    echo "  source ~/.bashrc"
    echo ""
    echo "  # For zsh users - add to ~/.zshrc:"
    echo "  echo 'export JETSON_HOST=your-jetson-ip-address' >> ~/.zshrc"
    echo "  source ~/.zshrc"
    echo ""
    echo "  # For fish users - add to ~/.config/fish/config.fish:"
    echo "  echo 'set -gx JETSON_HOST your-jetson-ip-address' >> ~/.config/fish/config.fish"
    echo ""
    exit 1
fi

# Check if infocmp command is available
if ! command -v infocmp >/dev/null 2>&1; then
    echo "Error: infocmp command not found. Please install ncurses-term or similar package."
    exit 1
fi

# Check if ssh command is available
if ! command -v ssh >/dev/null 2>&1; then
    echo "Error: ssh command not found. Please install openssh-client or similar package."
    exit 1
fi

echo "Installing Ghostty terminfo on remote host: $JETSON_HOST"
echo "This will extract xterm-ghostty terminfo and install it remotely via SSH..."

# Enable command tracing only for the main commands
set -x

# Execute the main command
# infocmp -x extracts terminfo in source format
# ssh connects to remote host and pipes the data
# tic -x - compiles and installs the terminfo from stdin
infocmp -x xterm-ghostty | ssh "$JETSON_HOST" -- tic -x -

# Disable command tracing
set +x

echo "Successfully installed Ghostty terminfo on $JETSON_HOST"
