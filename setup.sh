#!/bin/bash

set -e

SETUP_DIR="$(dirname "$0")/setup"

if [[ ! -d "$SETUP_DIR" ]]; then
    echo "Error: setup directory not found at $SETUP_DIR"
    exit 1
fi

scripts=($(find "$SETUP_DIR" -name "*.sh" -type f | sort))

if [[ ${#scripts[@]} -eq 0 ]]; then
    echo "No .sh scripts found in $SETUP_DIR"
    exit 0
fi

echo "Found ${#scripts[@]} scripts in setup directory"
echo

for script in "${scripts[@]}"; do
    script_name=$(basename "$script")
    
    while true; do
        read -p "Execute $script_name? [y/n/q]: " choice
        case $choice in
            [Yy]) 
                echo "Running $script_name..."
                if bash "$script"; then
                    echo "✓ $script_name completed successfully"
                else
                    echo "✗ $script_name failed (exit code $?)"
                    read -p "Continue with remaining scripts? [y/n]: " cont
                    [[ $cont =~ ^[Nn] ]] && exit 1
                fi
                break
                ;;
            [Nn]) 
                echo "Skipping $script_name"
                break
                ;;
            [Qq]) 
                echo "Quitting"
                exit 0
                ;;
            *) 
                echo "Please answer y, n, or q"
                ;;
        esac
    done
    echo
done

echo "Setup complete"
