#!/usr/bin/env bash

# Script to configure Git and GitHub on Jetson device
# Configures global Git settings, generates SSH key, and sets up commit signing

set -e  # Exit on any error
# set -x will be enabled only for actual commands, not echo statements

echo "Configuring Git and GitHub on Jetson device..."
echo "This will setup global Git configuration, SSH keys, and commit signing."
echo ""

# Get user information
read -p "Enter your Git user name (e.g., 'John Doe'): " GIT_USER_NAME
read -p "Enter your Git email address (e.g., 'john@example.com'): " GIT_USER_EMAIL
echo ""
echo "SSH Key Password (optional):"
echo "You can set a password for your SSH key for additional security,"
echo "or leave it empty for passwordless access."
read -s -p "Enter SSH key password (or press Enter for no password): " SSH_PASSWORD
echo ""

echo ""
echo "Configuring Git with:"
echo "  Name: $GIT_USER_NAME"
echo "  Email: $GIT_USER_EMAIL"
echo ""

# Enable command tracing only for the main commands
set -x

# Configure Git globally
git config --global user.name "$GIT_USER_NAME"
git config --global user.email "$GIT_USER_EMAIL"

# Generate SSH key for GitHub authentication
ssh-keygen -t ed25519 -C "$GIT_USER_EMAIL" -f ~/.ssh/id_ed25519 -N "$SSH_PASSWORD"

# Start ssh-agent and add the key
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519

# Configure Git to use SSH key for signing commits
git config --global gpg.format ssh
git config --global user.signingkey ~/.ssh/id_ed25519.pub
git config --global commit.gpgsign true
git config --global tag.gpgsign true

# Disable command tracing
set +x

echo ""
echo "Successfully configured Git and GitHub setup!"
echo ""
echo "=== SSH Key Setup ==="
echo "Your SSH public key (you'll need to add this TWICE to GitHub):"
echo ""
cat ~/.ssh/id_ed25519.pub
echo ""
echo "To add this SSH key to GitHub (you need to do this TWICE):"
echo ""
echo "STEP 1 - Add as Authentication Key:"
echo "1. Go to https://github.com/settings/keys"
echo "2. Click 'New SSH key'"
echo "3. Title: 'Jetson Device - Auth'"
echo "4. Key type: 'Authentication Key'"
echo "5. Paste the key above into the 'Key' field"
echo "6. Click 'Add SSH key'"
echo ""
echo "STEP 2 - Add as Signing Key:"
echo "1. Go to https://github.com/settings/keys (same page)"
echo "2. Click 'New SSH key' again"
echo "3. Title: 'Jetson Device - Signing'"
echo "4. Key type: 'Signing Key'"
echo "5. Paste the SAME key above into the 'Key' field"
echo "6. Click 'Add SSH key'"
echo ""
echo "Note: It's the same key content, but GitHub requires separate entries"
echo "for authentication and signing functionality."
echo ""
echo "=== Configuration Summary ==="
echo "Git user name: $(git config --global user.name)"
echo "Git email: $(git config --global user.email)"
echo "Signing format: $(git config --global gpg.format)"
echo "Signing key: $(git config --global user.signingkey)"
echo "Auto-sign commits: $(git config --global commit.gpgsign)"
echo ""
echo "After adding both keys to GitHub, all commits will be automatically signed!"
