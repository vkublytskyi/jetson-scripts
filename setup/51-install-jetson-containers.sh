#!/usr/bin/env bash

# Script to setup jetson-containers on Jetson device
# Clones repo, installs utilities, and switches to dev branch

set -e  # Exit on any error
# set -x will be enabled only for actual commands, not echo statements

echo "Setting up jetson-containers on Jetson device..."
echo "This will clone the repository, install utilities, and switch to dev branch."
echo ""
echo "Steps performed:"
echo "  1. Clone jetson-containers repository"
echo "  2. Run installer script (will prompt for sudo password)"
echo "  3. Switch to dev branch"
echo "  4. Optionally add personal fork as remote"
echo ""
echo "Note: The installer will setup Python requirements and add tools to PATH."
echo ""

# Ask about personal fork
echo "Personal Fork Setup (optional):"
echo "If you have a personal fork of jetson-containers, you can add it as a remote."
read -p "Do you have a personal fork? (y/N): " HAS_FORK

if [[ "$HAS_FORK" =~ ^[Yy]$ ]]; then
    read -p "Enter your GitHub username: " GITHUB_USER
    FORK_URL="git@github.com:${GITHUB_USER}/jetson-containers.git"
    echo "Will add fork: $FORK_URL"
    echo ""
fi

original_dir=$(pwd)

# Back to original working directory
cleanup() {
    cd "$original_dir"
}

trap cleanup EXIT

# Enable command tracing only for the main commands
set -x

# Clone the jetson-containers repository using SSH
git clone git@github.com:dusty-nv/jetson-containers.git $HOME/jetson_containers
cd $HOME/jetson_containers


# Run the installer script
bash ./install.sh

# Switch to dev branch after installation
git checkout dev

# Add personal fork as remote if provided
if [[ "$HAS_FORK" =~ ^[Yy]$ ]]; then
    # Rename origin to upstream (best practice for forks)
    git remote rename origin upstream
    # Add personal fork as origin
    git remote add origin "$FORK_URL"
    # Fetch from personal fork
    git fetch origin
fi

# Disable command tracing
set +x

echo ""
echo "Successfully setup jetson-containers!"
echo ""
echo "Current branch:"
cd jetson-containers && git branch --show-current
echo ""
echo "Remote repositories:"
git remote -v
echo ""
if [[ "$HAS_FORK" =~ ^[Yy]$ ]]; then
    echo "Git remotes configured:"
    echo "  origin -> your personal fork (for pushing changes)"
    echo "  upstream -> main dusty-nv repository (for pulling updates)"
    echo ""
    echo "Typical workflow:"
    echo "  git pull upstream dev    # Get latest changes from main repo"
    echo "  git push origin dev      # Push your changes to your fork"
else
    echo "Git remote configured:"
    echo "  origin -> main dusty-nv repository"
fi
echo ""
echo "jetson-containers is now installed and configured on dev branch."
echo "Tools like 'autotag' are now available in your PATH."
echo ""
echo "If you move the jetson-containers directory, re-run:"
echo "  bash jetson-containers/install.sh"
