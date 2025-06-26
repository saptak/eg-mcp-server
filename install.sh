#!/bin/bash

# Exit on error
set -e

# EGMCP Server Details
REPO="saptak/eg-mcp-server"

# Parse command line arguments
DRY_RUN=false
while [[ $# -gt 0 ]]; do
  case $1 in
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    *)
      echo "Unknown option $1"
      exit 1
      ;;
  esac
done

# Determine OS and Architecture
OS="$(uname -s | tr '[:upper:]' '[:lower:]')"
ARCH="$(uname -m)"

if [ "$ARCH" = "x86_64" ]; then
  ARCH="amd64"
fi

# Map OS names
case "$OS" in
  "darwin")
    OS="darwin"
    BINARY_NAME="egmcp-server-$OS-$ARCH"
    ;;
  "linux")
    OS="linux"  
    BINARY_NAME="egmcp-server-$OS-$ARCH"
    ;;
  "mingw"* | "msys"* | "cygwin"*)
    OS="windows"
    BINARY_NAME="egmcp-server-$OS-$ARCH.exe"
    ;;
  *)
    echo "Error: Unsupported operating system: $OS"
    exit 1
    ;;
esac

# Get the latest release version
LATEST_RELEASE=$(curl -s "https://api.github.com/repos/$REPO/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')

if [ -z "$LATEST_RELEASE" ]; then
  echo "Error: Could not determine the latest release."
  exit 1
fi

echo "Latest release: $LATEST_RELEASE"
echo "Target binary: $BINARY_NAME"

# Construct the download URL
DOWNLOAD_URL="https://github.com/$REPO/releases/download/$LATEST_RELEASE/$BINARY_NAME"

echo "Download URL: $DOWNLOAD_URL"

if [ "$DRY_RUN" = true ]; then
  echo "DRY RUN: Would download $BINARY_NAME and install to /usr/local/bin/egmcp-server"
  exit 0
fi

# Download and install the binary
INSTALL_DIR="/usr/local/bin"
BINARY_PATH="$INSTALL_DIR/egmcp-server"

echo "Downloading EGMCP Server from $DOWNLOAD_URL"
curl -L -o "/tmp/$BINARY_NAME" "$DOWNLOAD_URL"

echo "Installing to $BINARY_PATH"
sudo mv "/tmp/$BINARY_NAME" "$BINARY_PATH"
sudo chmod +x "$BINARY_PATH"

echo "EGMCP Server installed successfully!"

# Configure Claude Desktop
echo "Configuring Claude Desktop..."

# Determine Claude Desktop config path based on OS
case "$OS" in
  "darwin")
    CONFIG_DIR="$HOME/Library/Application Support/Claude"
    ;;
  "linux")
    CONFIG_DIR="$HOME/.config/Claude"
    ;;
  "windows")
    CONFIG_DIR="$APPDATA/Claude"
    ;;
esac

CONFIG_FILE="$CONFIG_DIR/claude_desktop_config.json"

# Create config directory if it doesn't exist
mkdir -p "$CONFIG_DIR"

# Check if config file exists
if [ -f "$CONFIG_FILE" ]; then
    echo "Found existing Claude Desktop configuration"
    # Check if egmcp-server is already configured
    if grep -q "egmcp-server" "$CONFIG_FILE" 2>/dev/null; then
        echo "✅ EGMCP Server already configured in Claude Desktop"
        echo "   Existing configuration preserved (no changes made)"
        echo "   To modify settings, edit: $CONFIG_FILE"
    else
        echo "Adding EGMCP Server to existing configuration..."
        # Backup existing config
        cp "$CONFIG_FILE" "$CONFIG_FILE.backup"
        
        # Escape binary path for JSON
        if [ "$OS" = "windows" ]; then
            BINARY_PATH_ESCAPED="${BINARY_PATH//\\/\\\\}"
        else
            BINARY_PATH_ESCAPED="$BINARY_PATH"
        fi
        
        # Use jq if available for safer JSON manipulation
        if command -v jq &> /dev/null; then
            echo "Using jq for safe JSON manipulation..."
            jq --arg cmd "$BINARY_PATH_ESCAPED" \
               '.mcpServers["egmcp-server"] = {
                  "command": $cmd,
                  "args": ["stdio-tools", "--envoy-url", "http://localhost:9901"],
                  "env": {}
                }' "$CONFIG_FILE" > "$CONFIG_FILE.tmp" && mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"
        else
            echo "jq not available, using manual JSON manipulation..."
            # Check if mcpServers section exists
            if grep -q '"mcpServers"' "$CONFIG_FILE"; then
                # Extract everything before the closing brace of mcpServers
                python3 -c "
import json
import sys

try:
    with open('$CONFIG_FILE', 'r') as f:
        config = json.load(f)
    
    # Ensure mcpServers exists
    if 'mcpServers' not in config:
        config['mcpServers'] = {}
    
    # Add or update egmcp-server
    config['mcpServers']['egmcp-server'] = {
        'command': '$BINARY_PATH_ESCAPED',
        'args': ['stdio-tools', '--envoy-url', 'http://localhost:9901'],
        'env': {}
    }
    
    with open('$CONFIG_FILE', 'w') as f:
        json.dump(config, f, indent=2)
    
    print('✅ Configuration updated successfully')
except Exception as e:
    print(f'❌ Error updating config: {e}')
    sys.exit(1)
" 2>/dev/null || {
                echo "❌ Failed to update configuration safely"
                echo "   Please manually add the following to your Claude Desktop config:"
                echo "   {"
                echo "     \"mcpServers\": {"
                echo "       \"egmcp-server\": {"
                echo "         \"command\": \"$BINARY_PATH_ESCAPED\","
                echo "         \"args\": [\"stdio-tools\", \"--envoy-url\", \"http://localhost:9901\"],"
                echo "         \"env\": {}"
                echo "       }"
                echo "     }"
                echo "   }"
                echo ""
                echo "   Config file location: $CONFIG_FILE"
                return 1
            }
            fi
        fi
        echo "✅ EGMCP Server added to Claude Desktop configuration"
    fi
else
    echo "Creating new Claude Desktop configuration..."
    cat > "$CONFIG_FILE" << EOF
{
  "mcpServers": {
    "egmcp-server": {
      "command": "$BINARY_PATH",
      "args": ["stdio-tools", "--envoy-url", "http://localhost:9901"],
      "env": {}
    }
  }
}
EOF
    echo "✅ Claude Desktop configuration created"
fi

echo ""
echo "🎉 Setup complete!"
echo ""
echo "Next steps:"
echo "1. Set up Envoy Gateway connection:"
echo "   curl -sSL https://raw.githubusercontent.com/saptak/eg-mcp-server/main/setup-envoy.sh | bash"
echo ""
echo "2. Restart Claude Desktop"
echo ""
echo "3. Ask Claude: 'What listeners are configured in Envoy Gateway?'"