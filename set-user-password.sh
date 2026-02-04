#!/bin/bash
#
# Quick script to set Linux user password
# This password is needed for installing software in GNOME/desktop
#

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Set Linux User Password               ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""

# Get the user (default to current user if not root, otherwise get from env)
if [ "$EUID" -eq 0 ]; then
    # Running as root
    if [ -n "$SUDO_USER" ]; then
        TARGET_USER="$SUDO_USER"
    else
        read -p "Enter username: " TARGET_USER
    fi
else
    TARGET_USER="$USER"
    echo -e "${YELLOW}Note: You'll need sudo privileges to set the password${NC}"
    echo ""
fi

echo -e "Setting password for user: ${GREEN}$TARGET_USER${NC}"
echo ""
echo -e "${YELLOW}This password is used for:${NC}"
echo "  • Installing software in GNOME Software/App Store"
echo "  • Running sudo commands"
echo "  • Any administrator tasks in the desktop"
echo ""
echo -e "${YELLOW}Note: This is different from your VNC password!${NC}"
echo "  • VNC password = for connecting to remote desktop"
echo "  • Linux password = for administrator tasks inside the desktop"
echo ""

# Set the password
if [ "$EUID" -eq 0 ]; then
    passwd "$TARGET_USER"
else
    sudo passwd "$TARGET_USER"
fi

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✓ Password set successfully!${NC}"
    echo ""
    echo -e "You can now use this password when GNOME asks for administrator credentials."
else
    echo ""
    echo -e "${RED}✗ Failed to set password${NC}"
    exit 1
fi
