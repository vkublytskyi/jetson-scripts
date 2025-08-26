#!/bin/bash

set -e

if [[ -z "$JETSON_HOST" ]]; then
    echo "Error: JETSON_HOST environment variable not set"
    echo "Usage: JETSON_HOST=jetson.local ./remote-setup.sh"
    exit 1
fi

SCRIPT_DIR="$(dirname "$0")"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
REMOTE_DIR="/tmp/jetson-setup-$"
SSH_SOCKET="/tmp/ssh-jetson-$"

cleanup() {
    ssh -S "$SSH_SOCKET" -O exit "$JETSON_HOST" 2>/dev/null || true
    rm -f "$SSH_SOCKET"
}
trap cleanup EXIT

echo "Establishing connection to Jetson device at $JETSON_HOST..."

# Create master connection
ssh -M -S "$SSH_SOCKET" -f -N "$JETSON_HOST"

if ! ssh -S "$SSH_SOCKET" "$JETSON_HOST" "echo 'Connection successful'"; then
    echo "Error: Cannot connect to $JETSON_HOST"
    exit 1
fi

echo "Copying setup files to Jetson..."
ssh -S "$SSH_SOCKET" "$JETSON_HOST" "mkdir -p $REMOTE_DIR"
scp -o "ControlPath=$SSH_SOCKET" -r "$PROJECT_DIR/setup.sh" "$PROJECT_DIR/setup/" "$JETSON_HOST:$REMOTE_DIR/"

echo "Making setup.sh executable..."
ssh -S "$SSH_SOCKET" "$JETSON_HOST" "chmod +x $REMOTE_DIR/setup.sh"

echo "Starting remote setup..."
ssh -S "$SSH_SOCKET" -t "$JETSON_HOST" "cd $REMOTE_DIR && ./setup.sh"

echo "Cleaning up remote files..."
ssh -S "$SSH_SOCKET" "$JETSON_HOST" "rm -rf $REMOTE_DIR"

echo "Remote setup complete"
