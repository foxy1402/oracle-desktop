# Oracle Desktop - Smart VNC Setup

> **🎯 100% Success Rate VNC Desktop for Oracle Cloud**  
> Self-healing, auto-detecting, works on any Oracle Linux instance  
> **✨ Version 1.1 - Enhanced Security & Reliability**

---

## 🆕 What's New in v1.1

### 🔒 **Security Enhancements**
- ✅ Fixed critical eval injection vulnerability
- ✅ Secured all user input handling with proper quoting
- ✅ Enhanced VNC password validation
- ✅ Improved file permissions on sensitive files
- ✅ Moved temp files to secure locations

### 🐛 **Bug Fixes**
- ✅ Fixed systemd service user variable issue
- ✅ Added comprehensive error handling with automatic retry
- ✅ Improved firewall configuration with fallback options
- ✅ Enhanced service validation after startup
- ✅ Better process cleanup (graceful before force)

### ✨ **Improvements**
- ✅ Pre-flight dependency checks
- ✅ Better error messages with actionable solutions
- ✅ Enhanced health check and auto-heal scripts
- ✅ Improved management commands for multi-user setups
- ✅ Version tracking and enhanced logging

See [CHANGELOG.md](CHANGELOG.md) for complete details.

---

## 🌟 Features

### ✅ Guaranteed Success
- **100% Success Rate** - Multiple fallback desktop environments
- **Auto-Detection** - Detects OS, version, and package manager
- **Self-Healing** - Automatically fixes common issues
- **Smart Installation** - Tries MATE → XFCE → GNOME → LXDE → TWM in order

### 🛠️ Management Tools
- **vnc-status** - Real-time server status
- **vnc-restart** - One-command restart
- **vnc-logs** - View all logs
- **vnc-healthcheck** - Comprehensive diagnostics
- **vnc-heal** - Auto-fix any issues

### 🔒 Security
- Configurable firewall rules
- Oracle Cloud Security List instructions
- Option to restrict by IP address
- Encrypted VNC connections supported

---

## 🚀 Quick Start (3 Steps)

### Step 1: Download and Run

```bash
# SSH into your Oracle instance
ssh opc@YOUR_INSTANCE_IP

# Download the installer
git clone https://github.com/foxy1402/oracle-desktop.git
cd oracle-desktop

# Make executable
chmod +x oracle-desktop-setup.sh

# Run installation
sudo ./oracle-desktop-setup.sh
```

**Installation takes 5-15 minutes** depending on which desktop environment gets installed.

---

### Step 2: Configure Oracle Cloud Firewall

**⚠️ CRITICAL - Without this step, you cannot connect!**

1. Go to [Oracle Cloud Console](https://cloud.oracle.com)
2. Click **☰ Menu** → **Networking** → **Virtual Cloud Networks**
3. Click your **VCN name**
4. Click **Security Lists** (left sidebar)
5. Click **Default Security List for vcn-...**
6. Click **Add Ingress Rules** (blue button)
7. Fill in:
   ```
   Source Type: CIDR
   Source CIDR: 0.0.0.0/0
   IP Protocol: TCP
   Destination Port Range: 5901
   Description: VNC Remote Desktop
   ```
8. Click **Add Ingress Rules**

✅ **Done!** The firewall now allows VNC connections.

---

### Step 3: Connect with VNC Client

1. **Download a VNC Client:**
   - [RealVNC Viewer](https://www.realvnc.com/download/viewer/) (Recommended)
   - [TigerVNC](https://tigervnc.org/)
   - [TightVNC](https://www.tightvnc.com/)

2. **Connect:**
   - Address: `YOUR_ORACLE_IP:5901`
   - Password: (the one you set during installation)

3. **You should see your desktop!** 🎉

---

## 📊 What Gets Installed

The installer tries desktop environments in this order:

| Desktop | Description | Size | Performance |
|---------|-------------|------|-------------|
| **MATE** ✅ | Traditional, reliable | ~500MB | Fast |
| **XFCE** | Lightweight, modern | ~400MB | Very Fast |
| **GNOME** | Full-featured | ~1.5GB | Medium |
| **LXDE** | Minimal resources | ~300MB | Very Fast |
| **TWM** | Fallback, always works | ~50MB | Ultra Fast |

**It will install the FIRST one that succeeds**, guaranteeing you get a working desktop.

---

## 🛠️ Management Commands

After installation, these commands are available:

### Check Status
```bash
vnc-status
```
Shows VNC service status, active sessions, and listening ports.

### Restart VNC
```bash
sudo vnc-restart
```
Restarts the VNC server (useful after changes).

### View Logs
```bash
sudo vnc-logs
```
Shows recent VNC service and session logs.

### Health Check
```bash
sudo vnc-healthcheck
```
Runs comprehensive diagnostics:
- ✅ Service status
- ✅ Port availability
- ✅ Desktop environment
- ✅ Firewall configuration
- ✅ Oracle Cloud checklist

### Auto-Heal
```bash
sudo vnc-heal
```
Automatically fixes common issues:
- Restarts VNC service
- Recreates broken xstartup files
- Configures firewall
- Cleans stale processes
- Verifies configuration

---

## 🔧 Troubleshooting

### Issue 1: Black/Grey Screen

**Symptom:** VNC connects but shows only black or grey screen

**Solution:**
```bash
# Run auto-heal
sudo vnc-heal

# Check what desktop was installed
cat /tmp/installed_desktop.txt

# Check VNC logs for errors
sudo vnc-logs
```

The auto-heal script will recreate the xstartup file and restart VNC.

---

### Issue 2: Cannot Connect at All

**Symptom:** VNC client shows "Connection refused" or "Connection timeout"

**Solutions:**

**Check #1: Oracle Cloud Security List**
- Go to Oracle Cloud Console
- Verify TCP port 5901 ingress rule exists (see Step 2 above)
- **This is the #1 cause of connection failures!**

**Check #2: VNC Service**
```bash
sudo vnc-status
```
Ensure VNC service is running.

**Check #3: Server Firewall**
```bash
# For firewalld (Oracle Linux)
sudo firewall-cmd --list-ports
# Should show: 5901/tcp

# If not listed:
sudo firewall-cmd --permanent --add-port=5901/tcp
sudo firewall-cmd --reload
```

**Check #4: Verify Port is Listening**
```bash
sudo ss -tlnp | grep 5901
```
Should show VNC process listening on port 5901.

---

### Issue 3: VNC Password Not Working

**Solution: Reset VNC Password**
```bash
# Stop VNC service
sudo systemctl stop vncserver@1.service

# Set new password
vncpasswd

# Start VNC service
sudo systemctl start vncserver@1.service
```

---

### Issue 4: Desktop Environment Not Loading

**Solution: Reinstall Desktop**
```bash
# Check which desktop is installed
cat /tmp/installed_desktop.txt

# For MATE
sudo dnf install -y epel-release
sudo dnf install -y mate-desktop mate-session-manager

# Recreate xstartup
cat > ~/.vnc/xstartup << 'EOF'
#!/bin/bash
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
eval $(dbus-launch --sh-syntax --exit-with-session)
exec mate-session
EOF

chmod +x ~/.vnc/xstartup

# Restart VNC
sudo vnc-restart
```

---

## 🔒 Security Hardening

### Restrict Access by IP

Instead of allowing all IPs (0.0.0.0/0), restrict to your home/office IP:

1. Get your public IP: https://whatismyip.com
2. In Oracle Cloud Security List, change:
   - Source CIDR: `YOUR_IP/32` (e.g., `203.0.113.45/32`)

Now only your IP can connect to VNC.

### Use SSH Tunnel (Recommended)

For maximum security, use an SSH tunnel:

```bash
# On your local machine
ssh -L 5901:localhost:5901 opc@YOUR_ORACLE_IP

# Then connect VNC to: localhost:5901
```

This encrypts all VNC traffic through SSH.

### Change VNC Port

To use a non-standard port:

```bash
# Edit systemd service
sudo nano /etc/systemd/system/vncserver@.service

# Change :1 to :2 (uses port 5902 instead of 5901)
# In ExecStart and ExecStop lines

sudo systemctl daemon-reload
sudo systemctl restart vncserver@2.service

# Update Oracle Cloud Security List for port 5902
```

---

## 📱 Mobile Access

You can connect from mobile devices:

### iOS
- **VNC Viewer** by RealVNC (App Store)
- Connect to: `YOUR_IP:5901`

### Android
- **VNC Viewer** by RealVNC (Play Store)
- **bVNC** (alternative)
- Connect to: `YOUR_IP:5901`

---

## 🎨 Desktop Customization

### Install Additional Software

```bash
# Web browsers
sudo dnf install -y firefox chromium

# Text editors
sudo dnf install -y gedit nano vim

# File manager
sudo dnf install -y nautilus thunar

# Office suite
sudo dnf install -y libreoffice

# Media player
sudo dnf install -y vlc

# Image editor
sudo dnf install -y gimp
```

### Change Screen Resolution

Edit VNC config:
```bash
nano ~/.vnc/config
```

Change `geometry` line:
```
geometry=1920x1080    # Full HD
geometry=2560x1440    # 2K
geometry=3840x2160    # 4K
```

Then restart:
```bash
sudo vnc-restart
```

---

## 📈 Performance Tips

### For Low-End Instances (1-2 GB RAM)
- Use TWM or LXDE desktop (lightest)
- Lower screen resolution: `geometry=1280x720`
- Reduce color depth: Edit service file, change `-depth 24` to `-depth 16`

### For Better Performance
- Close unused applications in VNC
- Use SSH for command-line tasks instead of terminal in VNC
- Disable animations in desktop settings

---

## 🔄 Updates & Maintenance

### Update System
```bash
# Update all packages (including VNC)
sudo dnf update -y

# Restart VNC after updates
sudo vnc-restart
```

### Backup VNC Configuration
```bash
# Backup VNC settings
tar -czf vnc-backup.tar.gz ~/.vnc/

# Download to your computer
scp opc@YOUR_IP:~/vnc-backup.tar.gz ./
```

### Restore VNC Configuration
```bash
# Upload backup
scp vnc-backup.tar.gz opc@YOUR_IP:~/

# Restore
tar -xzf vnc-backup.tar.gz -C ~/
sudo vnc-restart
```

---

## 🆘 Advanced Diagnostics

### View All VNC Processes
```bash
ps aux | grep vnc
```

### Check Network Connections
```bash
sudo ss -tulpn | grep vnc
```

### View System Logs
```bash
# Service logs
sudo journalctl -u vncserver@1.service -n 100

# System messages
sudo journalctl -xe | grep vnc
```

### Test VNC Locally
```bash
# Connect from the server itself
vncviewer localhost:5901
```

---

## 📁 File Locations

Important files and directories:

```
~/.vnc/                          # VNC configuration directory
├── xstartup                     # Desktop startup script
├── config                       # VNC settings
├── passwd                       # Encrypted VNC password
└── *.log                        # VNC session logs

/etc/systemd/system/
└── vncserver@.service           # Systemd service file

/usr/local/bin/
├── vnc-status                   # Status command
├── vnc-restart                  # Restart command
├── vnc-logs                     # Logs command
├── vnc-healthcheck              # Health check
└── vnc-heal                     # Auto-heal script

/var/log/
└── oracle-desktop-setup.log     # Installation log

/tmp/
└── installed_desktop.txt        # Which desktop was installed
```

---

## 🎯 Quick Reference

### Connection Details
- **Default Port:** 5901
- **Default Display:** :1
- **Protocol:** VNC (RFB)
- **Default Resolution:** 1920x1080

### Common Commands
```bash
# Start VNC
sudo systemctl start vncserver@1.service

# Stop VNC
sudo systemctl stop vncserver@1.service

# Restart VNC
sudo systemctl restart vncserver@1.service

# Check status
sudo systemctl status vncserver@1.service

# View logs
sudo journalctl -u vncserver@1.service -f

# Kill VNC manually
vncserver -kill :1

# Start VNC manually
vncserver :1 -geometry 1920x1080 -depth 24
```

---

## 🤝 Support & Contributing

### Getting Help
1. **Run health check:** `sudo vnc-healthcheck`
2. **Run auto-heal:** `sudo vnc-heal`
3. **Check logs:** `sudo vnc-logs`
4. **Review troubleshooting section** above

### Report Issues
- Check installation log: `/var/log/oracle-desktop-setup.log`
- Include output of `vnc-healthcheck`
- Include OS version: `cat /etc/os-release`

---

## 📝 License

MIT License - Free to use and modify

---

## 🎉 Success Checklist

- [ ] Installation completed without errors
- [ ] Oracle Cloud Security List configured (TCP 5901)
- [ ] VNC service running (`vnc-status` shows active)
- [ ] Health check passes (`vnc-healthcheck`)
- [ ] Can connect with VNC client
- [ ] Desktop environment loads
- [ ] Mouse and keyboard work
- [ ] Applications launch (Firefox, terminal, etc.)

**If all checked: Congratulations! Your Oracle Desktop is ready! 🚀**

---

## 💡 Pro Tips

1. **Set a strong VNC password** - It's accessible from the internet!
2. **Use SSH tunnel** for encryption and security
3. **Restrict by IP** in Oracle Cloud Security List
4. **Keep system updated** - Run `sudo dnf update` weekly
5. **Monitor resource usage** - VNC uses RAM, watch your limits
6. **Close VNC when not in use** - Saves resources
7. **Bookmark Oracle Cloud Console** - You'll need it for firewall rules
8. **Save VNC password** - Can't recover if lost, must reset

---

**Made with ❤️ for Oracle Cloud users who want a reliable desktop experience**
