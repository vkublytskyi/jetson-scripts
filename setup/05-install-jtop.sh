#!/usr/bin/env bash

# Script to install jtop monitoring tool on Jetson device
# Solution based on: https://jetsonhacks.com/2023/02/07/jtop-the-ultimate-tool-for-monitoring-nvidia-jetson-devices/

set -e  # Exit on any error
# set -x will be enabled only for actual commands, not echo statements

echo "Installing jtop (jetson-stats) monitoring tool..."
echo "jtop is the ultimate tool for monitoring NVIDIA Jetson devices."
echo ""
echo "Solution based on: https://jetsonhacks.com/2023/02/07/jtop-the-ultimate-tool-for-monitoring-nvidia-jetson-devices/"
echo ""
echo "Note: After installation, you will need to logout/login or reboot to use jtop."
echo ""

# Enable command tracing only for the main commands
set -x

# Install pip if not already available
sudo apt install -y python3-pip

# Install jetson-stats package using pip
sudo -H pip install -U jetson-stats

# Disable command tracing
set +x

echo ""
echo "Successfully installed jtop (jetson-stats)!"
echo ""
echo "IMPORTANT: You must logout/login or reboot before using jtop."
echo ""
echo "After reboot, you can run jtop with:"
echo "  jtop"
echo ""
echo "jtop features:"
echo "  - Real-time CPU, GPU, memory monitoring"
echo "  - Temperature and power consumption tracking"
echo "  - Fan control and power mode switching"
echo "  - Hardware information and system details"
echo ""
echo "Use 'jtop -h' for more options and help."
