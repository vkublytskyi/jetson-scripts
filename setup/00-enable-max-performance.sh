#!/usr/bin/env bash

# TODO: debug why device was not put in MAXN SUPER permanently. For now swithc in UI

# Script to enable maximum power mode on Jetson device
# Sets nvpmodel to mode 0 (typically MAXN - highest performance)

set -e  # Exit on any error
# set -x will be enabled only for actual commands, not echo statements

echo "Setting Jetson to maximum power mode (MAXN)..."
echo "This will configure the device for highest performance available."
echo ""
echo "Note: Maximum power mode requires adequate power supply (wall power recommended)."
echo ""

echo "Current power mode:"
# Enable command tracing only for the main commands
set -x

# Check current power mode
sudo nvpmodel -q

# Set to maximum power mode (mode 0)
sudo nvpmodel -m 0

# Disable command tracing
set +x

echo ""
echo "Maximum power mode has been set!"
echo ""
echo "Verifying new power mode:"

set -x
# Confirm the changes
sudo nvpmodel -q
set +x

echo ""
echo "Successfully configured Jetson for maximum performance!"
echo ""
echo "Note: Some power mode changes may require a reboot to take full effect."
echo "You can also monitor and change power modes using 'jtop' if installed."
