#!/usr/bin/env bash

# Script to configure Docker for Jetson device
# Sets nvidia as default runtime and adds user to docker group

set -e  # Exit on any error
# set -x will be enabled only for actual commands, not echo statements

echo "Configuring Docker for Jetson device..."
echo "This will set nvidia as default runtime and add current user to docker group."
echo ""
echo "Changes made:"
echo "  1. Configure /etc/docker/daemon.json with nvidia default runtime"
echo "  2. Add current user ($USER) to docker group"
echo "  3. Restart Docker service"
echo ""

# Create Docker daemon configuration
echo "Creating Docker daemon configuration..."

# Enable command tracing only for the main commands
set -x

# Create /etc/docker directory if it doesn't exist
sudo mkdir -p /etc/docker

# Create daemon.json with nvidia as default runtime
sudo tee /etc/docker/daemon.json > /dev/null << 'EOF'
{
    "runtimes": {
        "nvidia": {
            "path": "nvidia-container-runtime",
            "runtimeArgs": []
        }
    },
    "default-runtime": "nvidia"
}
EOF

# Add current user to docker group
sudo usermod -aG docker $USER

# Restart Docker service to apply changes
sudo systemctl restart docker

# Disable command tracing
set +x

echo ""
echo "Successfully configured Docker!"
echo ""
echo "Verifying configuration:"

set -x
# Verify the default runtime is set to nvidia
sudo docker info | grep 'Default Runtime' || echo "Default Runtime check failed - may need reboot"
set +x

echo ""
echo "Docker configuration completed!"
echo ""
echo "IMPORTANT: You need to logout/login or restart your terminal session"
echo "to use Docker commands without sudo (due to docker group membership)."
echo ""
echo "After logout/login, you can test with:"
echo "  docker info"
echo ""
echo "Your Docker is now configured with nvidia as the default runtime."
