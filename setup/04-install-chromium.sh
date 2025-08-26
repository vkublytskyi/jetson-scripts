#!/usr/bin/env bash

# Script to install Chromium on Jetson device
# Installs Chromium browser via snap

set -e  # Exit on any error
# set -x will be enabled only for actual commands, not echo statements

echo "Installing Chromium browser on Jetson device..."
echo "This will install Chromium via snap package manager."
echo ""
echo "Note: Make sure snap is working properly before running this script."
echo "If you're experiencing snap issues on Jetson Orin, run the snap fix script first."
echo ""

# Enable command tracing only for the main commands
set -x

# Install Chromium via snap
sudo snap install chromium

# Disable command tracing
set +x

echo ""
echo "Successfully installed Chromium!"
echo ""
echo "Chromium version:"
chromium --version 2>/dev/null || snap info chromium | grep "installed:"
echo ""
echo "You can now launch Chromium from:"
echo "  - Applications menu"
echo "  - Command line: chromium"
echo "  - Desktop launcher"
