#!/bin/bash
# AICHE Desktop - One-Click Installer
# Downloads from GitHub and bypasses Gatekeeper - No Apple Developer Account Required!

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}╔═══════════════════════════════════════╗${NC}"
echo -e "${GREEN}║     AICHE Desktop Quick Installer     ║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════╝${NC}"
echo ""

# Check if already installed
if [ -d "/Applications/AICHE Desktop.app" ]; then
    echo -e "${YELLOW}⚠️  AICHE Desktop is already installed.${NC}"
    read -p "Reinstall/Update? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 0
    fi
    echo "Removing old version..."
    rm -rf "/Applications/AICHE Desktop.app"
fi

# Download DMG from GitHub
echo -e "${GREEN}📥 Downloading AICHE Desktop...${NC}"
DMG_URL="https://github.com/AICHE-app/mac-releases/releases/download/v1.0.0/AICHE-Desktop.dmg"

# Create temp directory
TEMP_DIR=$(mktemp -d)
DMG_PATH="$TEMP_DIR/AICHE-Desktop.dmg"

# Download with progress bar
if command -v curl &> /dev/null; then
    curl -L -# -o "$DMG_PATH" "$DMG_URL"
else
    echo "Downloading (this may take a moment)..."
    wget -O "$DMG_PATH" "$DMG_URL"
fi

# Verify download
if [ ! -f "$DMG_PATH" ]; then
    echo -e "${RED}❌ Download failed!${NC}"
    rm -rf "$TEMP_DIR"
    exit 1
fi

# Mount DMG
echo -e "${GREEN}📦 Mounting installer...${NC}"
MOUNT_POINT=$(hdiutil attach "$DMG_PATH" -nobrowse -quiet | grep "AICHE Desktop" | cut -f 3)

if [ -z "$MOUNT_POINT" ]; then
    echo -e "${RED}❌ Failed to mount DMG${NC}"
    rm -rf "$TEMP_DIR"
    exit 1
fi

# Copy to Applications
echo -e "${GREEN}📋 Installing to Applications...${NC}"
cp -R "$MOUNT_POINT/AICHE Desktop.app" /Applications/

# Unmount DMG
hdiutil detach "$MOUNT_POINT" -quiet

# BYPASS GATEKEEPER - The Magic!
echo -e "${GREEN}🔓 Configuring security settings...${NC}"

# 1. Remove quarantine flag (bypass Gatekeeper)
xattr -rd com.apple.quarantine "/Applications/AICHE Desktop.app" 2>/dev/null || true

# 2. Clear all extended attributes
xattr -cr "/Applications/AICHE Desktop.app" 2>/dev/null || true

# 3. Ad-hoc sign locally (makes macOS trust it more)
if command -v codesign &> /dev/null; then
    codesign --force --deep --sign - "/Applications/AICHE Desktop.app" 2>/dev/null || true
fi

# 4. Try to add to Gatekeeper exception list (may require admin)
spctl --add "/Applications/AICHE Desktop.app" 2>/dev/null || true

# Clean up
rm -rf "$TEMP_DIR"

echo ""
echo -e "${GREEN}✅ Installation complete!${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo -e "${GREEN}🎯 AICHE Desktop is ready to use!${NC}"
echo "   NO security warnings!"
echo ""
echo "📝 To launch:"
echo "   • Click: Applications → AICHE Desktop"
echo "   • Or run: open '/Applications/AICHE Desktop.app'"
echo ""
echo "⌨️  Hotkeys:"
echo "   • Check the app for current hotkey bindings"
echo ""

# Ask if user wants to launch now
read -p "🚀 Launch AICHE Desktop now? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${GREEN}Launching AICHE Desktop...${NC}"
    open "/Applications/AICHE Desktop.app"
fi

echo ""
echo -e "${GREEN}Enjoy! 🎉${NC}"