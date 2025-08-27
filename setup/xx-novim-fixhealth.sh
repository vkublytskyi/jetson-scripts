#!/usr/bin/env bash

# Script to check Neovim health and display results in console
# Runs Neovim health checks and shows output in a readable format

set -e  # Exit on any error
# set -x will be enabled only for actual commands, not echo statements

echo "Running Neovim health check..."
echo "This will execute Neovim's built-in health diagnostics."
echo ""

# Check if Neovim is available
if ! command -v nvim >/dev/null 2>&1; then
    echo "❌ Error: Neovim (nvim) is not installed or not in PATH."
    echo ""
    echo "To install Neovim:"
    echo "  - Run our Neovim installation script"
    echo "  - Or install via package manager: sudo apt install neovim"
    exit 1
fi

echo "Neovim found: $(command -v nvim)"
echo "Neovim version:"
nvim --version | head -n 1
echo ""
echo "Running health diagnostics..."
echo "========================================"
echo ""

# Enable command tracing only for the main command
set -x

# Create a temporary file to capture health check output
TEMP_FILE=$(mktemp)

# Run Neovim with a more complex command to capture health check
nvim --headless -c 'checkhealth' -c 'normal ggVG' -c "write! $TEMP_FILE" -c 'qall!' 2>/dev/null

# If that doesn't work, try alternative method
if [ ! -s "$TEMP_FILE" ] || grep -q "Running healthchecks" "$TEMP_FILE"; then
    # Try using script to capture terminal output
    rm -f "$TEMP_FILE"
    script -q -c "nvim --headless -c 'checkhealth' -c 'qall!'" "$TEMP_FILE" >/dev/null 2>&1 || true
fi

# Disable command tracing
set +x

# Display the captured output
if [ -s "$TEMP_FILE" ]; then
    echo "Health Check Results:"
    echo "===================="
    # Clean up the output - remove script artifacts and "Running healthchecks..." line
    CLEAN_OUTPUT=$(sed -e '/^Running healthchecks\.\.\.$/d' \
        -e '/^Script started/d' \
        -e '/^Script done/d' \
        -e 's/\x1b\[[0-9;]*m//g' \
        -e '/^$/N;/^\n$/d' "$TEMP_FILE")
    
    echo "$CLEAN_OUTPUT"
    echo ""
    
    # Parse for fixable issues
    echo "Analyzing issues and attempting fixes..."
    echo "======================================"
    
    FIXES_APPLIED=false
    
    # Check for ripgrep
    if echo "$CLEAN_OUTPUT" | grep -q "WARNING.*ripgrep.*not available\|WARNING.*Could not find executable.*rg"; then
        echo "🔧 Installing ripgrep..."
        if sudo apt update && sudo apt install -y ripgrep; then
            echo "✅ Installed ripgrep"
            FIXES_APPLIED=true
        else
            echo "❌ Failed to install ripgrep"
        fi
    fi
    
    # Check for clipboard tools
    if echo "$CLEAN_OUTPUT" | grep -q "WARNING.*No clipboard tool found"; then
        echo "🔧 Installing clipboard tools..."
        if sudo apt install -y xclip wl-clipboard; then
            echo "✅ Installed clipboard tools (xclip, wl-clipboard)"
            FIXES_APPLIED=true
        else
            echo "❌ Failed to install clipboard tools"
        fi
    fi
    
    # Check for Python neovim module
    if echo "$CLEAN_OUTPUT" | grep -q "does not have the \"neovim\" module\|No Python executable found that can.*import neovim"; then
        echo "🔧 Installing Python neovim module..."
        if pip install pynvim 2>/dev/null || pip3 install pynvim; then
            echo "✅ Installed pynvim module"
            FIXES_APPLIED=true
        else
            echo "❌ Failed to install pynvim module"
        fi
    fi
    
    # Check for pip module missing
    if echo "$CLEAN_OUTPUT" | grep -q "No module named pip"; then
        echo "🔧 Installing python3-pip..."
        if sudo apt install -y python3-pip; then
            echo "✅ Installed python3-pip"
            FIXES_APPLIED=true
        else
            echo "❌ Failed to install python3-pip"
        fi
    fi
    
    # Check for Node.js/npm
    if echo "$CLEAN_OUTPUT" | grep -q "WARNING.*node.*not available\|WARNING.*npm.*not available\|node.*and.*npm.*must be in.*PATH"; then
        echo "🔧 Installing Node.js and npm..."
        if sudo apt install -y nodejs npm; then
            echo "✅ Installed Node.js and npm"
            FIXES_APPLIED=true
            
            # Also install neovim npm package
            echo "🔧 Installing neovim npm package..."
            if npm install -g neovim; then
                echo "✅ Installed neovim npm package"
            else
                echo "❌ Failed to install neovim npm package"
            fi
        else
            echo "❌ Failed to install Node.js and npm"
        fi
    fi
    
    # Check for luarocks/hererocks issues
    if echo "$CLEAN_OUTPUT" | grep -q "ERROR.*luarocks.*not installed\|WARNING.*lua.*version.*not installed\|WARNING.*Lazy won't be able to install plugins that require.*luarocks"; then
        echo "🔧 Setting up LuaRocks via hererocks for lazy.nvim..."
        
        # Check if Python is available (required for hererocks)
        if command -v python3 >/dev/null 2>&1; then
            # Install required build dependencies for Lua compilation
            echo "Installing build dependencies for Lua..."
            if sudo apt install -y libreadline-dev build-essential; then
                echo "✅ Installed build dependencies"
            else
                echo "❌ Failed to install build dependencies"
                return
            fi
            
            # Install hererocks if not present
            if [ ! -f ~/.local/share/nvim/lazy-rocks/hererocks/hererocks.py ]; then
                mkdir -p ~/.local/share/nvim/lazy-rocks/hererocks
                curl -L https://raw.githubusercontent.com/luarocks/hererocks/latest/hererocks.py -o ~/.local/share/nvim/lazy-rocks/hererocks/hererocks.py
            fi
            
            # Install Lua 5.1 and LuaRocks via hererocks
            if python3 ~/.local/share/nvim/lazy-rocks/hererocks/hererocks.py ~/.local/share/nvim/lazy-rocks/hererocks --lua=5.1 --luarocks=latest; then
                echo "✅ Installed Lua 5.1 and LuaRocks via hererocks"
                FIXES_APPLIED=true
            else
                echo "❌ Failed to install Lua/LuaRocks via hererocks"
                echo "You can disable luarocks in lazy.nvim config with: opts.rocks.enabled = false"
            fi
        else
            echo "❌ Python3 required for hererocks installation"
        fi
    fi
    
    # Check for missing neovim npm package (when Node.js/npm are available)
    if echo "$CLEAN_OUTPUT" | grep -q "WARNING.*Missing.*neovim.*npm.*package\|Run in shell.*npm install -g neovim"; then
        echo "🔧 Installing neovim npm package..."
        if command -v npm >/dev/null 2>&1; then
            if npm install -g neovim; then
                echo "✅ Installed neovim npm package"
                FIXES_APPLIED=true
            else
                echo "❌ Failed to install neovim npm package"
            fi
        else
            echo "❌ npm not available, cannot install neovim package"
        fi
    fi
    
    # Check for tree-sitter
    if echo "$CLEAN_OUTPUT" | grep -q "WARNING.*tree-sitter.*executable not found"; then
        echo "🔧 Installing tree-sitter..."
        if command -v npm >/dev/null 2>&1 && npm install -g tree-sitter-cli 2>/dev/null; then
            echo "✅ Installed tree-sitter CLI"
            FIXES_APPLIED=true
        else
            echo "❌ Failed to install tree-sitter CLI (npm may not be available)"
        fi
    fi
    
    MANUAL_FIXES=false
    
    # Check for Ruby
    if echo "$CLEAN_OUTPUT" | grep -q "WARNING.*ruby.*not available\|WARNING.*gem.*not available"; then
        echo "🔍 Ruby/RubyGems not available:"
        echo "   sudo apt install ruby-full"
        echo "   gem install neovim"
        MANUAL_FIXES=true
    fi
    
    # Check for Go
    if echo "$CLEAN_OUTPUT" | grep -q "WARNING.*Go.*not available"; then
        echo "🔍 Go not available:"
        echo "   Install from: https://golang.org/dl/"
        MANUAL_FIXES=true
    fi
    
    # Check for Rust/Cargo
    if echo "$CLEAN_OUTPUT" | grep -q "WARNING.*cargo.*not available"; then
        echo "🔍 Rust/Cargo not available:"
        echo "   curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"
        MANUAL_FIXES=true
    fi
    
    # Check for Java
    if echo "$CLEAN_OUTPUT" | grep -q "WARNING.*java.*not available\|WARNING.*javac.*not available"; then
        echo "🔍 Java/JDK not available:"
        echo "   sudo apt install default-jdk"
        MANUAL_FIXES=true
    fi
    
    # Check for PHP/Composer
    if echo "$CLEAN_OUTPUT" | grep -q "WARNING.*php.*not available\|WARNING.*composer.*not available"; then
        echo "🔍 PHP/Composer not available:"
        echo "   sudo apt install php php-cli composer"
        MANUAL_FIXES=true
    fi
    
    # Check for luarocks (if not fixed by hererocks above)
    if echo "$CLEAN_OUTPUT" | grep -q "WARNING.*luarocks.*not available" && ! echo "$CLEAN_OUTPUT" | grep -q "hererocks"; then
        echo "🔍 System LuaRocks not available:"
        echo "   sudo apt install luarocks"
        echo "   Or disable with: opts.rocks.enabled = false in lazy.nvim config"
        MANUAL_FIXES=true
    fi
    
    if [ "$MANUAL_FIXES" = false ]; then
        echo "No remaining issues that require manual intervention."
    fi
    
    echo ""
    if [ "$FIXES_APPLIED" = true ]; then
        echo "🎉 Some issues were automatically fixed!"
        echo "   Run this script again to see updated health status."
    else
        echo "ℹ️  No issues could be automatically fixed."
    fi
    
    # Clean up temp file
    rm "$TEMP_FILE"
else
    echo "⚠️  Unable to capture health check output automatically."
    echo ""
    echo "Please run health check manually:"
    echo "  nvim -c 'checkhealth'"
    echo ""
    echo "Common health check categories:"
    echo "  • nvim: Basic Neovim installation"
    echo "  • provider.clipboard: System clipboard"
    echo "  • provider.python: Python integration" 
    echo "  • provider.node: Node.js integration"
    echo "  • provider.ruby: Ruby integration"
    echo ""
    echo "To check specific category:"
    echo "  nvim -c 'checkhealth provider.python'"
fi

echo ""
echo "========================================"
echo "Health check completed!"
echo ""
echo "Legend:"
echo "  ✓ OK       - Feature is working correctly"
echo "  ! WARNING  - Feature has minor issues but works"
echo "  ✗ ERROR    - Feature has problems that need attention"
echo ""
echo "For more detailed information, run: nvim -c 'checkhealth'"
