#!/usr/bin/env bash

# Script to fix snap issues on Jetson Orin
# Solution based on: https://jetsonhacks.com/2025/07/12/why-chromium-suddenly-broke-on-jetson-orin-and-how-to-bring-it-back/

set -e  # Exit on any error
# set -x will be enabled only for actual commands, not echo statements

echo "Fixing snap issues on Jetson Orin..."
echo "This will downgrade snapd to revision 24724 and hold it to prevent auto-updates."
echo ""
echo "Solution based on: https://jetsonhacks.com/2025/07/12/why-chromium-suddenly-broke-on-jetson-orin-and-how-to-bring-it-back/"
echo ""
echo "Note: This process will download and install a specific snapd version."
echo ""

# Enable command tracing only for the main commands
set -x

# Download specific snapd revision that works with Jetson Orin
snap download snapd --revision=24724

# Acknowledge the downloaded snap assertion
sudo snap ack snapd_24724.assert

# Install the specific snapd revision
sudo snap install snapd_24724.snap

# Hold snapd to prevent automatic updates that could break it again
sudo snap refresh --hold snapd

# Disable command tracing
set +x

echo ""
echo "Successfully fixed snap configuration!"
echo ""
echo "Current snapd version:"
snap version
echo ""
echo "snapd is now held at revision 24724 and will not auto-update."
echo "Chromium and other snaps should now work properly on Jetson Orin."
