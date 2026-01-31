# Oracle Desktop - Quick Start Guide

**⏱️ Total Time: 15-20 minutes**

---

## 📋 Before You Start

You need:
- ✅ Oracle Cloud account (free tier is fine)
- ✅ Oracle Linux 8 or 9 instance running
- ✅ SSH access to your instance
- ✅ Instance's public IP address

---

## 🚀 Step-by-Step Installation

### Step 1: Connect to Your Server (2 minutes)

**On Windows:**
```cmd
ssh opc@YOUR_INSTANCE_IP
```

**On Mac/Linux:**
```bash
ssh opc@YOUR_INSTANCE_IP
```

Replace `YOUR_INSTANCE_IP` with your actual Oracle instance IP.

---

### Step 2: Download Oracle Desktop (1 minute)

```bash
# Install git if needed
sudo dnf install -y git

# Download Oracle Desktop
git clone https://github.com/yourusername/oracle-desktop.git
cd oracle-desktop

# Make the installer executable
chmod +x oracle-desktop-setup.sh
```

---

### Step 3: Run the Installer (10-15 minutes)

```bash
sudo ./oracle-desktop-setup.sh
```

**What happens:**
1. Detects your OS and configuration
2. Updates system packages
3. Installs VNC server
4. Tries to install desktop environments (MATE → XFCE → GNOME → LXDE → TWM)
5. Configures VNC server
6. Sets up firewall
7. Creates management commands
8. **Asks you to set a VNC password** ← Write this down!

**During installation:**
- You'll be asked to set a VNC password - **remember this!**
- Installation progress is shown on screen
- Takes 5-15 minutes depending on which desktop installs

✅ **Installation complete when you see the green "INSTALLATION COMPLETE!" banner**

---

### Step 4: Configure Oracle Cloud Firewall (3 minutes)

**⚠️ CRITICAL - Your VNC won't work without this!**

1. Open a web browser
2. Go to https://cloud.oracle.com
3. Log in
4. Click the **☰** hamburger menu (top left)
5. Click **Networking**
6. Click **Virtual Cloud Networks**
7. Click your VCN name (e.g., "vcn-20250131-...")
8. On the left sidebar, click **Security Lists**
9. Click **Default Security List for vcn-...**
10. Click the blue **Add Ingress Rules** button
11. Fill in the form:
    - **Source Type:** CIDR (leave as is)
    - **Source CIDR:** `0.0.0.0/0`
    - **IP Protocol:** TCP (click dropdown, select TCP)
    - **Source Port Range:** (leave empty)
    - **Destination Port Range:** `5901`
    - **Description:** `VNC Remote Desktop`
12. Click **Add Ingress Rules** at the bottom
13. You should see the new rule appear in the list

✅ **Firewall configured!**

---

### Step 5: Connect with VNC (2 minutes)

#### Download VNC Client

Choose one:
- **RealVNC Viewer** (Recommended): https://www.realvnc.com/download/viewer/
- **TigerVNC**: https://tigervnc.org/
- **TightVNC**: https://www.tightvnc.com/

#### Connect

1. Open your VNC client
2. Enter connection address: `YOUR_INSTANCE_IP:5901`
   - Example: `203.0.113.45:5901`
3. Click **Connect**
4. Enter the VNC password you set during installation
5. Press **Enter**

🎉 **You should now see your desktop!**

---

## ✅ Verification

After connecting, you should see:

- ✅ A desktop with taskbar/menu
- ✅ Working mouse cursor
- ✅ Ability to right-click
- ✅ Applications menu accessible
- ✅ Terminal or file manager opens

---

## ❌ Troubleshooting

### Problem 1: Black or Grey Screen

**Fix:**
```bash
# In SSH, run:
sudo vnc-heal

# Wait 30 seconds, then reconnect with VNC
```

---

### Problem 2: Connection Refused

**Most likely: Oracle Cloud Security List not configured**

**Fix:**
1. Go back to Step 4
2. Verify the ingress rule exists
3. Check port is 5901, protocol is TCP
4. Check source CIDR is 0.0.0.0/0

**Also check server firewall:**
```bash
sudo vnc-status
```
Should show VNC service is running.

---

### Problem 3: Wrong Password

**Fix: Reset VNC Password**
```bash
# Stop VNC
sudo systemctl stop vncserver@1.service

# Set new password
vncpasswd

# Start VNC
sudo systemctl start vncserver@1.service
```

---

## 🛠️ Quick Commands

After installation, these commands help manage your desktop:

```bash
# Check if VNC is running
vnc-status

# Restart VNC server
sudo vnc-restart

# View logs
sudo vnc-logs

# Run health check
sudo vnc-healthcheck

# Auto-fix issues
sudo vnc-heal
```

---

## 🔒 Security Tips

### For Better Security:

1. **Restrict by IP address:**
   - In Oracle Cloud Security List, change source CIDR from `0.0.0.0/0` to `YOUR_HOME_IP/32`
   - Get your IP from: https://whatismyip.com

2. **Use SSH tunnel:**
   ```bash
   # On your local machine
   ssh -L 5901:localhost:5901 opc@YOUR_INSTANCE_IP
   
   # Then connect VNC to: localhost:5901
   ```

3. **Use strong VNC password:**
   - At least 8 characters
   - Mix of letters, numbers, symbols

---

## 📱 Mobile Access

You can also connect from your phone/tablet!

**iOS:**
1. Install "VNC Viewer" from App Store
2. Add new connection: `YOUR_IP:5901`
3. Enter VNC password
4. Connect

**Android:**
1. Install "VNC Viewer" from Play Store
2. Add new connection: `YOUR_IP:5901`
3. Enter VNC password
4. Connect

---

## 🎨 What's Installed

Your desktop includes:

- 🌐 **Firefox** web browser
- 📁 **File manager**
- 💻 **Terminal**
- 📝 **Text editor**
- ⚙️ **Settings/Control panel**

To install more software:
```bash
# In VNC terminal or SSH
sudo dnf install -y libreoffice    # Office suite
sudo dnf install -y vlc             # Media player
sudo dnf install -y gimp            # Image editor
```

---

## 📈 Resource Usage

**Expected RAM usage:**

| Desktop | RAM Usage |
|---------|-----------|
| TWM | ~200 MB |
| LXDE | ~300 MB |
| XFCE | ~400 MB |
| MATE | ~500 MB |
| GNOME | ~800 MB |

Oracle Cloud free tier has 1-6 GB RAM depending on ARM vs x86.

---

## 🔄 Common Tasks

### Change Screen Resolution

```bash
nano ~/.vnc/config
```

Change the `geometry` line:
```
geometry=1920x1080    # Full HD (default)
geometry=1280x720     # HD (uses less bandwidth)
geometry=2560x1440    # 2K
```

Save and run: `sudo vnc-restart`

---

### Stop VNC When Not Using

To save resources:
```bash
sudo systemctl stop vncserver@1.service
```

To start again:
```bash
sudo systemctl start vncserver@1.service
```

---

### Update System

Once a week:
```bash
sudo dnf update -y
sudo vnc-restart
```

---

## 📞 Need Help?

1. **Run diagnostics:**
   ```bash
   sudo vnc-healthcheck
   ```

2. **Auto-fix issues:**
   ```bash
   sudo vnc-heal
   ```

3. **Check logs:**
   ```bash
   sudo vnc-logs
   ```

4. **Review README.md** for detailed troubleshooting

---

## 🎉 Success Checklist

- [ ] Installation completed without errors
- [ ] VNC password set and remembered
- [ ] Oracle Cloud Security List configured
- [ ] VNC client installed on your computer
- [ ] Can connect to `YOUR_IP:5901`
- [ ] Desktop loads and is usable
- [ ] Mouse and keyboard work

**All checked? You're done! Enjoy your Oracle Desktop! 🚀**

---

## 💡 Pro Tips

1. **Bookmark your instance IP** - You'll use it often
2. **Save your VNC password** - Can't recover if lost
3. **Keep Oracle Cloud Console open** - Useful for managing firewall
4. **Use SSH for command-line work** - Faster than VNC terminal
5. **Close VNC when done** - Saves server resources

---

**Need the full documentation? Read [README.md](README.md)**

**Questions? Issues? Run `vnc-healthcheck` first!**
