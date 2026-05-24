#!/bin/sh
set -e

REPO="Elytra-Security/elytrus"
BIN_DIR="${ELYTRUS_INSTALL_DIR:-/usr/local/bin}"
BINARY="elytrus"

# Detect OS and architecture
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)

case "$ARCH" in
  x86_64)  ARCH="amd64" ;;
  aarch64) ARCH="arm64" ;;
  arm64)   ARCH="arm64" ;;
  *)
    echo "Unsupported architecture: $ARCH"
    exit 1
    ;;
esac

case "$OS" in
  linux|darwin) ;;
  *)
    echo "Unsupported OS: $OS. For Windows, download from:"
    echo "https://github.com/${REPO}/releases/latest"
    exit 1
    ;;
esac

BINARY_NAME="elytrus-${OS}-${ARCH}"

echo "Installing Elytrus..."
echo "  Platform: ${OS}/${ARCH}"

# Get latest release URL
LATEST_URL="https://github.com/${REPO}/releases/latest/download"

# Download binary
TMP=$(mktemp)
echo "  Downloading ${BINARY_NAME}..."
curl -sSfL "${LATEST_URL}/${BINARY_NAME}" -o "$TMP"

# Download checksums and verify
echo "  Verifying checksum..."
CHECKSUM_FILE=$(mktemp)
curl -sSfL "${LATEST_URL}/checksums.txt" -o "$CHECKSUM_FILE"

# Extract expected checksum for this binary
EXPECTED=$(grep "${BINARY_NAME}" "$CHECKSUM_FILE" | awk '{print $1}')
if [ -z "$EXPECTED" ]; then
  echo "  Warning: Could not find checksum for ${BINARY_NAME}, skipping verification"
else
  ACTUAL=$(sha256sum "$TMP" | awk '{print $1}')
  if [ "$EXPECTED" != "$ACTUAL" ]; then
    echo "  Checksum verification failed!"
    echo "  Expected: $EXPECTED"
    echo "  Actual:   $ACTUAL"
    rm -f "$TMP" "$CHECKSUM_FILE"
    exit 1
  fi
  echo "  Checksum verified."
fi

rm -f "$CHECKSUM_FILE"

# Install binary
chmod +x "$TMP"
if [ -w "$BIN_DIR" ]; then
  mv "$TMP" "${BIN_DIR}/${BINARY}"
else
  echo "  Installing to ${BIN_DIR} (requires sudo)..."
  sudo mv "$TMP" "${BIN_DIR}/${BINARY}"
fi

echo ""
echo "Elytrus installed to ${BIN_DIR}/${BINARY}"
echo ""
elytrus version
echo ""
echo "Next steps:"
echo "  cd your-project"
echo "  elytrus init"
echo "  elytrus gate --strict"
