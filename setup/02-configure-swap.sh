#!/usr/bin/env bash

# Script to configure swap on Jetson device
# Allocates swap space equal to 2x RAM size

set -e  # Exit on any error
# set -x will be enabled only for actual commands, not echo statements

# Get total RAM in GB (programmatically)
RAM_KB=$(grep MemTotal /proc/meminfo | awk '{print $2}')
RAM_GB=$((RAM_KB / 1024 / 1024))
SWAP_GB=$((RAM_GB * 2))

echo "Configuring swap on local Jetson device..."
echo "Detected RAM: ${RAM_GB}GB"
echo "Creating swap file: ${SWAP_GB}GB (2x RAM)"
echo ""
echo "Note: This process may take a few minutes to allocate the swap file."
echo ""

# Check if swap is already configured
CURRENT_SWAP=$(free -h | grep Swap | awk '{print $2}')
if [ "$CURRENT_SWAP" != "0B" ]; then
    echo "Warning: Swap is already configured ($CURRENT_SWAP)"
    echo "Proceeding will disable existing swap and create new one."
    echo ""
fi

# Enable command tracing only for the main commands
set -x

# Disable any existing swap
sudo swapoff -a

# Create swap file (using fallocate for speed)
sudo fallocate -l ${SWAP_GB}G /swapfile

# Set proper permissions
sudo chmod 600 /swapfile

# Make it a swap file
sudo mkswap /swapfile

# Enable the swap file
sudo swapon /swapfile

# Make swap permanent by adding to /etc/fstab
# First remove any existing swap entries, then add new one
sudo sed -i '/\/swapfile/d' /etc/fstab
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab

# Disable command tracing
set +x

echo ""
echo "Successfully configured swap!"
echo ""
echo "Current memory status:"
free -h
echo ""
echo "Swap configuration will persist after reboot."
