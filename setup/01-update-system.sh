#!/usr/bin/env bash

# Script to upgrade freshly installed Jetson device locally
# Runs system update and full upgrade on the local system

set -e  # Exit on any error
# set -x will be enabled only for actual commands, not echo statements

echo "Starting system upgrade on local Jetson device..."
echo "This will update package lists and perform a full system upgrade."
echo ""
echo "Note: This process may take several minutes depending on the number of updates available."
echo ""

# Enable command tracing only for the main commands
set -x

# Update package lists
sudo apt update

# Install essential packages
sudo apt install -y curl

# Perform full system upgrade
# -y flag automatically answers yes to prompts
sudo apt full-upgrade -y

# Create ~/.local/bin directory 
mkdir -p ~/.local/bin

# Check if ~/.local/bin PATH configuration exists in ~/.profile
# Look for the standard Jetson .profile pattern
if grep -q 'HOME/\.local/bin' ~/.profile 2>/dev/null; then
    PATH_CONFIG_EXISTS=true
    echo "Found existing ~/.local/bin PATH configuration in ~/.profile"
else
    # Add ~/.local/bin to PATH in ~/.profile (fallback, shouldn't be needed on fresh Jetson)
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.profile
    PATH_CONFIG_EXISTS=false
    echo "Added ~/.local/bin PATH configuration to ~/.profile"
fi

# Check if ~/.local/bin is in current session's PATH
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    # Source ~/.profile to update current session
    source ~/.profile
    RELOADED_PATH=true
else
    RELOADED_PATH=false
fi

# Disable command tracing
set +x

echo ""
echo "Successfully completed system upgrade!"
echo ""
echo "Installed packages:"
echo "  ✓ curl (for downloading files)"
echo ""
echo "Created directory:"
echo "  ✓ ~/.local/bin (for user binaries)"
echo ""

if [ "$PATH_CONFIG_EXISTS" = true ]; then
    if [ "$RELOADED_PATH" = true ]; then
        echo "✓ ~/.local/bin PATH config found in ~/.profile (Jetson default)"
        echo "✓ Loaded ~/.local/bin into current session"
    else
        echo "✓ ~/.local/bin is already configured and active"
    fi
else
    echo "✓ Added ~/.local/bin PATH configuration to ~/.profile"
    echo "✓ ~/.local/bin is now available in current session"
fi
echo ""
echo "System information after upgrade:"
lsb_release -a 2>/dev/null || echo "lsb_release not available"
echo ""
echo "Optional: You may want to reboot if kernel updates were installed:"
echo "  sudo reboot"
