#!/bin/bash

###############################################################################
# Oracle Desktop - Uninstall Script
# Completely removes Oracle Desktop and all components
###############################################################################

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${YELLOW}"
cat << "EOF"
╔═══════════════════════════════════════════════════════════╗
║                                                           ║
║          Oracle Desktop - Uninstall                      ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

# Check root
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}This script must be run as root${NC}"
   echo "Please run: sudo $0"
   exit 1
fi

# Get real user
if [ -n "$SUDO_USER" ]; then
    REAL_USER=$SUDO_USER
else
    REAL_USER=$(whoami)
fi

echo -e "${YELLOW}Warning: This will remove Oracle Desktop and all VNC configurations${NC}"
echo ""
echo "This will:"
echo "  • Stop VNC server"
echo "  • Remove VNC configuration files"
echo "  • Remove systemd service"
echo "  • Remove management scripts"
echo "  • Close firewall ports"
echo "  • Optionally remove desktop environment"
echo ""
read -p "Are you sure you want to uninstall? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo "Uninstall cancelled."
    exit 0
fi

echo ""
echo -e "${BLUE}[1/7]${NC} Stopping VNC server..."
systemctl stop vncserver@1.service 2>/dev/null || true
systemctl disable vncserver@1.service 2>/dev/null || true
vncserver -kill :1 2>/dev/null || true
pkill -9 Xvnc 2>/dev/null || true
echo -e "${GREEN}✓ VNC server stopped${NC}"

echo -e "${BLUE}[2/7]${NC} Removing systemd service..."
rm -f /etc/systemd/system/vncserver@.service
systemctl daemon-reload
echo -e "${GREEN}✓ Systemd service removed${NC}"

echo -e "${BLUE}[3/7]${NC} Removing management scripts..."
rm -f /usr/local/bin/vnc-status
rm -f /usr/local/bin/vnc-restart
rm -f /usr/local/bin/vnc-logs
rm -f /usr/local/bin/vnc-healthcheck
rm -f /usr/local/bin/vnc-heal
echo -e "${GREEN}✓ Management scripts removed${NC}"

echo -e "${BLUE}[4/7]${NC} Removing VNC configuration..."
REAL_HOME=$(eval echo ~$REAL_USER)
rm -rf "$REAL_HOME/.vnc"
echo -e "${GREEN}✓ VNC configuration removed${NC}"

echo -e "${BLUE}[5/7]${NC} Closing firewall ports..."
if command -v firewall-cmd >/dev/null 2>&1; then
    firewall-cmd --permanent --remove-port=5901/tcp 2>/dev/null || true
    firewall-cmd --reload 2>/dev/null || true
fi
iptables -D INPUT -p tcp --dport 5901 -j ACCEPT 2>/dev/null || true
echo -e "${GREEN}✓ Firewall ports closed${NC}"

echo -e "${BLUE}[6/7]${NC} Removing logs and temporary files..."
rm -f /var/log/oracle-desktop-setup.log
rm -f /tmp/installed_desktop.txt
echo -e "${GREEN}✓ Logs removed${NC}"

echo -e "${BLUE}[7/7]${NC} Removing VNC server..."
echo ""
read -p "Do you want to uninstall TigerVNC server? (yes/no): " remove_vnc

if [ "$remove_vnc" = "yes" ]; then
    if command -v dnf >/dev/null 2>&1; then
        dnf remove -y tigervnc-server tigervnc-server-module
    elif command -v apt >/dev/null 2>&1; then
        apt remove -y tigervnc-standalone-server tigervnc-common
    fi
    echo -e "${GREEN}✓ VNC server uninstalled${NC}"
else
    echo -e "${YELLOW}! VNC server kept (manual removal: dnf remove tigervnc-server)${NC}"
fi

# Ask about desktop environment
echo ""
DESKTOP=$(cat /tmp/installed_desktop.txt 2>/dev/null || echo "unknown")
if [ "$DESKTOP" != "unknown" ] && [ "$DESKTOP" != "twm" ]; then
    echo -e "${YELLOW}Desktop environment detected: $DESKTOP${NC}"
    read -p "Do you want to remove the desktop environment? (yes/no): " remove_desktop
    
    if [ "$remove_desktop" = "yes" ]; then
        case $DESKTOP in
            mate)
                dnf groupremove -y "MATE Desktop" 2>/dev/null || \
                dnf remove -y mate-desktop mate-session-manager 2>/dev/null
                ;;
            xfce)
                dnf groupremove -y "Xfce" 2>/dev/null || \
                dnf remove -y @xfce-desktop-environment 2>/dev/null
                ;;
            gnome)
                dnf groupremove -y "Server with GUI" 2>/dev/null || \
                dnf groupremove -y "GNOME Desktop" 2>/dev/null
                ;;
            lxde)
                dnf remove -y @lxde-desktop 2>/dev/null
                ;;
        esac
        echo -e "${GREEN}✓ Desktop environment removed${NC}"
    else
        echo -e "${YELLOW}! Desktop environment kept${NC}"
    fi
fi

# Final cleanup
echo ""
echo -e "${BLUE}Running final cleanup...${NC}"
if command -v dnf >/dev/null 2>&1; then
    dnf autoremove -y
    dnf clean all
fi

echo ""
echo -e "${GREEN}"
cat << "EOF"
╔═══════════════════════════════════════════════════════════╗
║                                                           ║
║          ✓ Uninstall Complete                            ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

echo "Oracle Desktop has been removed from your system."
echo ""
echo -e "${YELLOW}Note:${NC} Oracle Cloud Security List rules are not automatically removed."
echo "To remove manually:"
echo "  1. Go to Oracle Cloud Console"
echo "  2. Navigate to: Networking → VCN → Security Lists"
echo "  3. Remove the ingress rule for port 5901"
echo ""
echo -e "${GREEN}Thank you for using Oracle Desktop!${NC}"
