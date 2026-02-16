# VNC Desktop for Oracle Cloud & Ubuntu

> **One-command VNC desktop installation for Oracle Linux and Ubuntu**  
> Works on Oracle Cloud, any Ubuntu server, and RHEL-based systems

---

## 📋 What This Does

Automatically installs and configures:
- ✅ VNC server (remote desktop access)
- ✅ Desktop environment (MATE, XFCE, GNOME, or LXDE)
- ✅ Firefox browser
- ✅ Firewall configuration
- ✅ Auto-start on reboot

**Supported Systems:**
- Oracle Linux 8.x, 9.x
- Ubuntu 20.04, 22.04+ (including Minimal)
- Debian 10, 11, 12
- RHEL, Rocky Linux, AlmaLinux 8.x, 9.x

**Architectures:** x86_64 (amd64), aarch64 (arm64)

---

## 🚀 Quick Installation

### Step 1: Run the installer

```bash
# Download and run
git clone https://github.com/foxy1402/oracle-desktop.git
cd oracle-desktop
chmod +x oracle-desktop-setup.sh
sudo ./oracle-desktop-setup.sh
```

**Installation takes 5-15 minutes.** You'll be prompted to set a VNC password.

---

### Step 2: Configure Firewall

**For Oracle Cloud:**

1. Go to [Oracle Cloud Console](https://cloud.oracle.com)
2. Navigate: **☰ Menu** → **Networking** → **Virtual Cloud Networks**
3. Click your VCN → **Security Lists** → **Default Security List**
4. Click **Add Ingress Rules**
5. Enter:
   - Source CIDR: `0.0.0.0/0`
   - IP Protocol: `TCP`
   - Destination Port: `5901`
6. Click **Add Ingress Rules**

**For Ubuntu (non-Oracle Cloud):**

```bash
# Check if UFW is configured (script does this automatically)
sudo ufw status | grep 5901

# If not configured, run:
sudo ufw allow 5901/tcp
sudo ufw reload
```

---

### Step 3: Connect

1. **Download VNC Viewer:**
   - [RealVNC Viewer](https://www.realvnc.com/download/viewer/) (Recommended)
   - [TigerVNC Viewer](https://tigervnc.org/)

2. **Connect to your server:**
   - Address: `YOUR_SERVER_IP:5901`
   - Password: *(VNC password you set during installation)*

3. **You should see your desktop!** 🎉

---

## 🔑 Important: Two Different Passwords

### 1️⃣ VNC Password (for remote connection)
- Set during installation
- Used to connect with VNC Viewer

### 2️⃣ Linux User Password (for installing software)
- Needed to install apps from GUI or run `sudo` commands
- Set with:

```bash
# For Oracle Linux (opc user)
sudo passwd opc

# For Ubuntu (ubuntu user)
sudo passwd ubuntu

# Or use the helper script
cd oracle-desktop
chmod +x set-user-password.sh
sudo ./set-user-password.sh
```

**Without setting the Linux password, you can't install software from the GUI!**

---

## 📦 Installing Software

### Via Terminal (No password needed for sudo):
```bash
# Oracle Linux
sudo dnf install firefox chromium libreoffice vlc

# Ubuntu
sudo apt install firefox chromium-browser libreoffice vlc
```

### Via GUI Software Store (Needs Linux password):
1. Open "Software" app
2. Search for application
3. Click "Install"
4. Enter your **Linux user password** when prompted

---

## 🛠️ Management Commands

After installation, these commands are available:

```bash
# Check VNC status
vnc-status

# Restart VNC server
sudo vnc-restart

# View logs
sudo vnc-logs

# Run diagnostics
sudo vnc-healthcheck

# Auto-fix common issues
sudo vnc-heal
```

---

## 🐛 Troubleshooting

### Cannot Connect to VNC

**Check 1:** Oracle Cloud Security List configured? (See Step 2 above)

**Check 2:** VNC server running?
```bash
sudo ss -tlnp | grep 5901
# Should show VNC listening on port 5901
```

**Check 3:** Firewall open?
```bash
# Oracle Linux
sudo firewall-cmd --list-ports | grep 5901

# Ubuntu
sudo ufw status | grep 5901
```

**Fix:** Restart VNC
```bash
vncserver -kill :1
vncserver :1 -geometry 1920x1080 -depth 24 -localhost no
```

---

### Black or Grey Screen

**Fix:** Recreate xstartup file

```bash
# Check which desktop is installed
cat /etc/oracle-desktop-type

# For MATE
cat > ~/.vnc/xstartup << 'EOF'
#!/bin/bash
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
eval $(dbus-launch --sh-syntax --exit-with-session)
exec mate-session
EOF

# For XFCE
cat > ~/.vnc/xstartup << 'EOF'
#!/bin/bash
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
eval $(dbus-launch --sh-syntax --exit-with-session)
exec startxfce4
EOF

# For GNOME
cat > ~/.vnc/xstartup << 'EOF'
#!/bin/bash
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
eval $(dbus-launch --sh-syntax --exit-with-session)
exec gnome-session
EOF

# Make executable and restart
chmod +x ~/.vnc/xstartup
vncserver -kill :1
vncserver :1 -geometry 1920x1080 -depth 24 -localhost no
```

---

### Can't Install Software (Password Doesn't Work)

**Problem:** Using VNC password instead of Linux password

**Solution:** Set your Linux user password
```bash
# Oracle Linux
sudo passwd opc

# Ubuntu
sudo passwd ubuntu
```

---

## ⚙️ Advanced Configuration

### Change Resolution

```bash
nano ~/.vnc/config

# Edit geometry line:
geometry=1280x720    # Lower resolution
geometry=1920x1080   # Full HD (default)
geometry=2560x1440   # 2K

# Restart VNC
sudo vnc-restart
```

### Enable Auto-Start on Reboot

```bash
sudo systemctl enable vncserver@1.service
sudo systemctl start vncserver@1.service
```

### Security: Restrict Access by IP

In Oracle Cloud Security List, change:
- Source CIDR from `0.0.0.0/0` to `YOUR_IP/32`

For Ubuntu UFW:
```bash
sudo ufw delete allow 5901/tcp
sudo ufw allow from YOUR_IP to any port 5901 proto tcp
```

---

## 📊 Desktop Environments

The installer tries desktops in this order (installs the first that succeeds):

| Desktop | Size | RAM Usage | Best For |
|---------|------|-----------|----------|
| **MATE** | ~500MB | Low | Oracle Cloud free tier |
| **XFCE** | ~400MB | Very Low | Ubuntu Minimal |
| **GNOME** | ~1.5GB | Medium | Full-featured desktop |
| **LXDE** | ~300MB | Very Low | Minimal resources |
| **TWM** | ~50MB | Minimal | Emergency fallback |

---

## 🔐 Security Notes

- VNC traffic is **not encrypted by default**
- For production use, consider SSH tunneling:
  ```bash
  # On your local machine
  ssh -L 5901:localhost:5901 opc@YOUR_SERVER_IP
  
  # Then connect VNC to: localhost:5901
  ```
- Set a strong VNC password (8+ characters)
- Set a strong Linux user password
- Restrict firewall to your IP if possible

---

## 💡 Tips

1. **Use SSH tunnel** for encrypted VNC connection
2. **Lower resolution** if connection is slow (edit `~/.vnc/config`)
3. **Close VNC when not using** to save resources
4. **Keep system updated**: `sudo dnf update -y` or `sudo apt update && sudo apt upgrade -y`
5. **Monitor resources** with `htop` or `top`

---

## 📝 File Locations

Important files and directories:

```
~/.vnc/
├── passwd          # Encrypted VNC password
├── config          # VNC settings (resolution, etc)
├── xstartup        # Desktop startup script
└── *.log           # VNC session logs

/etc/systemd/system/
└── vncserver@.service   # Systemd service template

/etc/oracle-desktop-type          # Which desktop was installed
```

---

## 🆘 Getting Help

**Quick diagnostics:**
```bash
sudo vnc-healthcheck
```

**View logs:**
```bash
sudo vnc-logs
tail -f ~/.vnc/*.log
```

**Auto-fix issues:**
```bash
sudo vnc-heal
```

**Check VNC process:**
```bash
ps aux | grep vnc
sudo ss -tlnp | grep 5901
```

---

## ✅ Success Checklist

- [ ] Installation completed without errors
- [ ] VNC password set
- [ ] Linux user password set
- [ ] Firewall configured (port 5901 open)
- [ ] Can connect with VNC Viewer
- [ ] Desktop loads (not black/grey screen)
- [ ] Can install Firefox or other software
- [ ] Mouse and keyboard work

**All checked? You're ready to use your remote desktop!** 🎉

---

## 📄 License

MIT License - Free to use and modify

---

**Made with ❤️ for Oracle Cloud and Ubuntu users who want a simple remote desktop**
