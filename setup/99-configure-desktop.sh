#!/usr/bin/env bash

# Script to clean Ubuntu dock and pin only specific applications
# This script works with GNOME Shell favorite-apps setting

set -e  # Exit on any error

echo "Cleaning Ubuntu dock and pinning specific applications..."
echo "This will replace all current dock favorites with:"
echo "  - Ghostty terminal"
echo "  - Neovim (from ~/.local/bin/nvim)"
echo "  - Chromium browser"
echo "  - File browser (Nautilus)"
echo ""

# Function to check if a desktop file exists
check_desktop_file() {
    local desktop_file="$1"
    local search_paths=(
        "/usr/share/applications/"
        "/var/lib/snapd/desktop/applications/"
        "$HOME/.local/share/applications/"
    )
    
    for path in "${search_paths[@]}"; do
        if [[ -f "${path}${desktop_file}" ]]; then
            echo "Found: ${path}${desktop_file}"
            return 0
        fi
    done
    
    echo "Warning: Desktop file '${desktop_file}' not found in standard locations"
    return 1
}

# Function to create a desktop file for Neovim if it doesn't exist
create_neovim_desktop() {
    local nvim_path="$HOME/.local/bin/nvim"
    local desktop_file="$HOME/.local/share/applications/nvim.desktop"
    local desktop_icon="$HOME/.local/share/applications/nvim.png"
    
    if [[ ! -f "$nvim_path" ]]; then
        echo "Warning: Neovim not found at $nvim_path"
        echo "Please ensure Neovim is installed at the specified location"
        return 1
    fi

    # Create the directory if it doesn't exist
    mkdir -p "$HOME/.local/share/applications"
    
    curl -o $desktop_icon https://raw.githubusercontent.com/neovim/neovim/refs/heads/master/runtime/nvim.png
    
    # Create the desktop file
    cat > "$desktop_file" << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Neovim
GenericName=Text Editor
Comment=Vim-based text editor
Exec=ghostty --class=com.github.neovim -e nvim %F
Icon=$desktop_icon
Categories=Utility;TextEditor;Development;
Keywords=text;editor;vim;nvim;
MimeType=text/plain;text/x-makefile;text/x-c++hdr;text/x-c++src;text/x-chdr;text/x-csrc;text/x-java;text/x-moc;text/x-pascal;text/x-tcl;text/x-tex;application/x-shellscript;text/x-c;text/x-c++;
StartupNotify=false
StartupWMClass=com.github.neovim
EOF

    # Make it executable
    chmod +x "$desktop_file"
    echo "Created Neovim desktop file at $desktop_file"
}

echo "Checking for required applications..."
echo ""

# List of desktop files we want to pin (in order)
declare -a desktop_files=(
    "ghostty_ghostty.desktop"        # Ghostty (snap)
    "nvim.desktop"                   # Neovim (custom desktop file)
    "chromium_chromium.desktop"      # Chromium (snap)
    "org.gnome.Nautilus.desktop"     # File browser
)

# Final list of desktop files that exist
declare -a final_apps=()

# Check Ghostty
if check_desktop_file "ghostty_ghostty.desktop"; then
    final_apps+=("'ghostty_ghostty.desktop'")
else
    echo "Warning: Ghostty desktop file not found. Please ensure Ghostty is installed."
    echo "If you built from source, the desktop file might have a different name."
fi

# Check/Create Neovim desktop file
if create_neovim_desktop; then
    final_apps+=("'nvim.desktop'")
fi

# Check Chromium
if check_desktop_file "chromium_chromium.desktop"; then
    final_apps+=("'chromium_chromium.desktop'")
else
    echo "Warning: Chromium desktop file not found. Please ensure Chromium is installed."
fi

# Check Nautilus (File browser)
if check_desktop_file "org.gnome.Nautilus.desktop"; then
    final_apps+=("'org.gnome.Nautilus.desktop'")
else
    echo "Warning: Nautilus desktop file not found."
fi

echo ""
echo "Current dock favorites:"
gsettings get org.gnome.shell favorite-apps

echo ""
if [[ ${#final_apps[@]} -eq 0 ]]; then
    echo "Error: No valid desktop files found. Cannot update dock."
    exit 1
fi

# Join the array elements with commas
IFS=','
apps_string="[${final_apps[*]}]"
unset IFS

echo "Setting new dock favorites..."
echo "New favorites: $apps_string"

# Enable command tracing only for the main command
set -x

# Set the new favorite apps
gsettings set org.gnome.shell favorite-apps "$apps_string"

# Disable command tracing
set +x

echo ""
echo "Successfully updated dock favorites!"
echo ""
echo "Updated dock favorites:"
gsettings get org.gnome.shell favorite-apps

echo ""
echo "Note: If some applications don't appear immediately, try:"
echo "  - Logging out and back in"
echo "  - Running: update-desktop-database ~/.local/share/applications"
echo "  - Restarting GNOME Shell (Alt+F2, type 'r', press Enter)"

