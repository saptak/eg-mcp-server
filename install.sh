#!/bin/bash

# Exit on error
set -e

# EGMCP Server Details
REPO="saptak/eg-mcp-server"

# Determine OS and Architecture
OS="$(uname -s | tr '[:upper:]' '[:lower:]')"
ARCH="$(uname -m)"

if [ "$ARCH" = "x86_64" ]; then
  ARCH="amd64"
fi

# Get the latest release version
LATEST_RELEASE=$(curl -s "https://api.github.com/repos/$REPO/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')

if [ -z "$LATEST_RELEASE" ]; then
  echo "Error: Could not determine the latest release."
  exit 1
fi

# Construct the download URL
DOWNLOAD_URL="https://github.com/$REPO/releases/download/$LATEST_RELEASE/egmcp-server-$LATEST_RELEASE-$OS-$ARCH.tar.gz"

# Download and extract the binary
INSTALL_DIR="/usr/local/bin"

TEMP_DIR=$(mktemp -d)

cd $TEMP_DIR

echo "Downloading EGMCP Server from $DOWNLOAD_URL"
curl -sSL "$DOWNLOAD_URL" | tar -xz

# Install the binary
echo "Installing egmcp-server to $INSTALL_DIR"
sudo mv egmcp-server $INSTALL_DIR

# Clean up
cd -
rm -rf $TEMP_DIR

echo "EGMCP Server installed successfully!"

