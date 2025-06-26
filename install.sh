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
echo "Run 'egmcp-server --help' to get started."