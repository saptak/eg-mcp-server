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
    else
        echo "Adding EGMCP Server to existing configuration..."
        # Backup existing config
        cp "$CONFIG_FILE" "$CONFIG_FILE.backup"
        
        # Add egmcp-server to existing config (simple approach - append before closing brace)
        if [ "$OS" = "windows" ]; then
            BINARY_PATH_ESCAPED="${BINARY_PATH//\\/\\\\}"
        else
            BINARY_PATH_ESCAPED="$BINARY_PATH"
        fi
        
        # Remove the last closing brace and add our server config
        sed '$ s/}//' "$CONFIG_FILE" > "$CONFIG_FILE.tmp"
        echo '    ,' >> "$CONFIG_FILE.tmp"
        echo '    "egmcp-server": {' >> "$CONFIG_FILE.tmp"
        echo '      "command": "'$BINARY_PATH_ESCAPED'",' >> "$CONFIG_FILE.tmp"
        echo '      "args": ["stdio-tools", "--envoy-url", "http://localhost:9901"],' >> "$CONFIG_FILE.tmp"
        echo '      "env": {}' >> "$CONFIG_FILE.tmp"
        echo '    }' >> "$CONFIG_FILE.tmp"
        echo '  }' >> "$CONFIG_FILE.tmp"
        echo '}' >> "$CONFIG_FILE.tmp"
        mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"
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