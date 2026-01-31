# Oracle Desktop - Troubleshooting Guide

Complete solutions for every possible issue.

---

## 🔍 Diagnostic Flowchart

```
Can you connect to VNC at all?
│
├─ NO → Issue 1: Cannot Connect
│   ├─ Oracle Cloud Security List not configured (90% of cases)
│   ├─ Server firewall blocking
│   ├─ VNC service not running
│   └─ Wrong IP or port
│
└─ YES → What do you see?
    │
    ├─ Black screen → Issue 2: Black Screen
    │   ├─ Desktop not starting
    │   └─ xstartup file broken
    │
    ├─ Grey screen → Issue 3: Grey Screen
    │   ├─ TWM installed but no apps launching
    │   └─ Need to right-click for menu
    │
    ├─ Desktop but slow → Issue 4: Performance
    │   ├─ Too heavy desktop for instance
    │   └─ Too high resolution
    │
    └─ Desktop works! → You're done! 🎉
```

---

## ❌ Issue 1: Cannot Connect to VNC

### Symptom
- VNC client shows "Connection refused"
- VNC client shows "Connection timeout"
- VNC client shows "No route to host"

### Root Causes & Solutions

#### Cause 1.1: Oracle Cloud Security List Not Configured (90% of issues)

**This is the #1 reason VNC doesn't work!**

**Solution:**
1. Go to https://cloud.oracle.com
2. Click ☰ Menu → Networking → Virtual Cloud Networks
3. Click your VCN name
4. Click Security Lists → Default Security List
5. Verify there's an ingress rule for:
   - Protocol: TCP
   - Port: 5901
   - Source: 0.0.0.0/0

**If rule doesn't exist:**
1. Click "Add Ingress Rules"
2. Fill in:
   - Source CIDR: `0.0.0.0/0`
   - IP Protocol: TCP
   - Destination Port Range: `5901`
3. Click "Add Ingress Rules"

**Verification:**
```bash
# From your local machine, test if port is accessible:
telnet YOUR_INSTANCE_IP 5901
# Or:
nc -zv YOUR_INSTANCE_IP 5901
```

---

#### Cause 1.2: VNC Service Not Running

**Check:**
```bash
sudo vnc-status
```

**Solution if service is stopped:**
```bash
sudo systemctl start vncserver@1.service

# Check status again
sudo vnc-status
```

**If service fails to start:**
```bash
# View detailed logs
sudo journalctl -u vncserver@1.service -n 50

# Common fixes:
# Fix 1: Remove lock file
rm -f ~/.vnc/*.pid

# Fix 2: Kill stale processes
vncserver -kill :1
sudo pkill -9 Xvnc

# Fix 3: Restart service
sudo systemctl restart vncserver@1.service
```

---

#### Cause 1.3: Server Firewall Blocking

**Check firewall:**
```bash
# For firewalld (Oracle Linux)
sudo firewall-cmd --list-ports

# Should show: 5901/tcp
```

**Solution if port not listed:**
```bash
sudo firewall-cmd --permanent --add-port=5901/tcp
sudo firewall-cmd --reload

# Verify
sudo firewall-cmd --list-ports
```

**Check if port is listening:**
```bash
sudo ss -tlnp | grep 5901

# Should show something like:
# LISTEN  0  5  *:5901  *:*  users:(("Xvnc",pid=12345,fd=6))
```

**If port not listening:**
```bash
# Restart VNC
sudo vnc-restart

# Check again
sudo ss -tlnp | grep 5901
```

---

#### Cause 1.4: Wrong Connection Details

**Verify your connection:**
```bash
# Get your public IP
curl ifconfig.me

# Verify VNC is listening
sudo ss -tlnp | grep vnc
```

**Common mistakes:**
- ❌ Using private IP instead of public IP
- ❌ Wrong port (should be 5901, not 5900)
- ❌ Wrong display number (should be :1)
- ❌ Typo in IP address

**Correct connection format:**
- VNC address: `PUBLIC_IP:5901`
- Example: `203.0.113.45:5901`

---

## ❌ Issue 2: Black Screen

### Symptom
- VNC connects successfully
- Shows only black screen
- No mouse cursor or cursor doesn't move
- No desktop elements visible

### Solutions

#### Solution 2.1: Run Auto-Heal (Easiest)

```bash
# In SSH terminal
sudo vnc-heal

# Wait 30 seconds
# Disconnect and reconnect VNC
```

This fixes most black screen issues automatically.

---

#### Solution 2.2: Check Which Desktop Was Installed

```bash
# Check installed desktop
cat /tmp/installed_desktop.txt

# Check if desktop components exist
which mate-session    # For MATE
which startxfce4      # For XFCE  
which gnome-session   # For GNOME
which startlxde       # For LXDE
```

**If command not found, desktop isn't installed:**
```bash
# Reinstall desktop (example for MATE)
sudo dnf install -y epel-release
sudo dnf install -y mate-desktop mate-session-manager marco

# Update installed desktop tracker
echo "mate" | sudo tee /tmp/installed_desktop.txt

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

#### Solution 2.3: Fix xstartup File

**Check if xstartup exists and is executable:**
```bash
ls -la ~/.vnc/xstartup
```

**Recreate xstartup:**

For MATE:
```bash
cat > ~/.vnc/xstartup << 'EOF'
#!/bin/bash
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS

# Start D-Bus
if [ -z "$DBUS_SESSION_BUS_ADDRESS" ]; then
    eval $(dbus-launch --sh-syntax --exit-with-session)
fi

# Load resources
[ -r $HOME/.Xresources ] && xrdb $HOME/.Xresources

# Start MATE
exec mate-session
EOF

chmod +x ~/.vnc/xstartup
sudo vnc-restart
```

For GNOME:
```bash
cat > ~/.vnc/xstartup << 'EOF'
#!/bin/bash
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS

eval $(dbus-launch --sh-syntax --exit-with-session)
[ -r $HOME/.Xresources ] && xrdb $HOME/.Xresources

exec gnome-session
EOF

chmod +x ~/.vnc/xstartup
sudo vnc-restart
```

For TWM (always works):
```bash
cat > ~/.vnc/xstartup << 'EOF'
#!/bin/sh
[ -r $HOME/.Xresources ] && xrdb $HOME/.Xresources
xsetroot -solid grey
xterm -geometry 100x30+50+50 &
exec twm
EOF

chmod +x ~/.vnc/xstartup
sudo vnc-restart
```

---

#### Solution 2.4: Check VNC Logs

```bash
# View VNC session logs
cat ~/.vnc/*.log

# Look for errors like:
# - "command not found" → Desktop not installed
# - "cannot open display" → X server issue
# - "dbus" errors → D-Bus not starting
```

**Common log errors and fixes:**

**Error: `/usr/bin/mate-session: not found`**
```bash
# MATE not installed, install it:
sudo dnf install -y epel-release
sudo dnf install -y mate-desktop mate-session-manager
```

**Error: `dbus-launch: command not found`**
```bash
# Install D-Bus tools:
sudo dnf install -y dbus-x11
```

**Error: `cannot open display`**
```bash
# X server not starting, reinstall VNC:
sudo dnf reinstall -y tigervnc-server
```

---

## ❌ Issue 3: Grey Screen (TWM Working)

### Symptom
- VNC shows grey screen
- No windows or menus visible
- Actually working correctly! TWM is minimal

### Solution

TWM is a minimal window manager - this is normal! Here's how to use it:

**To open applications:**
1. **Right-click** anywhere on the grey background
2. You'll see a menu with options
3. Click "xterm" to open a terminal
4. From terminal, launch apps: `firefox &`

**If right-click doesn't show menu:**

```bash
# Recreate xstartup with better apps
cat > ~/.vnc/xstartup << 'EOF'
#!/bin/sh
[ -r $HOME/.Xresources ] && xrdb $HOME/.Xresources
xsetroot -solid '#2E3440'

# Auto-start apps
xterm -geometry 100x30+50+50 -bg black -fg white &
firefox &

# Start window manager
exec twm
EOF

chmod +x ~/.vnc/xstartup
sudo vnc-restart
```

Now when you connect, you'll automatically see:
- A terminal window
- Firefox browser
- Right-click still works for menu

**To upgrade to a better desktop:**
```bash
# Install MATE
sudo dnf install -y epel-release
sudo dnf install -y mate-desktop mate-session-manager marco

# Update xstartup
cat > ~/.vnc/xstartup << 'EOF'
#!/bin/bash
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
eval $(dbus-launch --sh-syntax --exit-with-session)
exec mate-session
EOF

chmod +x ~/.vnc/xstartup
sudo vnc-restart
```

---

## ❌ Issue 4: Poor Performance / Slow

### Symptoms
- Desktop is laggy
- Mouse movement slow
- Windows take forever to open
- High CPU usage

### Solutions

#### Solution 4.1: Use Lighter Desktop

Check current desktop:
```bash
cat /tmp/installed_desktop.txt
```

**Desktop performance ranking (fastest to slowest):**
1. TWM (fastest, but minimal)
2. LXDE
3. XFCE
4. MATE
5. GNOME (slowest, most resource-heavy)

**Switch to lighter desktop:**
```bash
# Install LXDE (very light)
sudo dnf install -y epel-release
sudo dnf install -y @lxde-desktop

cat > ~/.vnc/xstartup << 'EOF'
#!/bin/bash
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
eval $(dbus-launch --sh-syntax --exit-with-session)
exec startlxde
EOF

chmod +x ~/.vnc/xstartup
echo "lxde" | sudo tee /tmp/installed_desktop.txt
sudo vnc-restart
```

---

#### Solution 4.2: Lower Screen Resolution

```bash
# Edit VNC config
nano ~/.vnc/config
```

Change geometry:
```
# From:
geometry=1920x1080

# To:
geometry=1280x720    # HD
# Or:
geometry=1366x768    # Laptop resolution
```

Save and restart:
```bash
sudo vnc-restart
```

---

#### Solution 4.3: Reduce Color Depth

```bash
# Edit systemd service
sudo nano /etc/systemd/system/vncserver@.service
```

Find the `ExecStart` line and change `-depth 24` to `-depth 16`:
```
ExecStart=/usr/bin/vncserver :%i -geometry 1920x1080 -depth 16 -localhost no
```

Save, then:
```bash
sudo systemctl daemon-reload
sudo systemctl restart vncserver@1.service
```

---

#### Solution 4.4: Check Instance Resources

```bash
# Check RAM usage
free -h

# Check CPU usage
top

# Check disk usage
df -h
```

**If RAM is maxed out:**
- Upgrade Oracle instance to higher memory
- Or use lighter desktop (TWM/LXDE)
- Close unnecessary applications

---

## ❌ Issue 5: VNC Password Problems

### Issue 5.1: Forgot VNC Password

**Solution: Reset password**
```bash
# Stop VNC
sudo systemctl stop vncserver@1.service

# Remove old password
rm -f ~/.vnc/passwd

# Set new password
vncpasswd

# Start VNC
sudo systemctl start vncserver@1.service
```

---

### Issue 5.2: Password Not Being Accepted

**Solutions:**

**Try 1: Check for typos**
- VNC passwords are case-sensitive
- Check Caps Lock
- Try typing slowly

**Try 2: Recreate password file**
```bash
sudo systemctl stop vncserver@1.service
rm -f ~/.vnc/passwd
vncpasswd
sudo systemctl start vncserver@1.service
```

**Try 3: Check VNC client compatibility**
- Some older VNC clients have password issues
- Try a different VNC client
- Recommended: RealVNC Viewer (latest version)

---

## ❌ Issue 6: Oracle Cloud Specific Issues

### Issue 6.1: Instance Not Responding

**Check instance status:**
1. Go to Oracle Cloud Console
2. Navigate to Compute → Instances
3. Check instance state

**If "Stopped":**
- Click "Start"
- Wait 2-3 minutes
- Try connecting again

**If "Running" but not responding:**
```bash
# Try to connect via SSH
ssh opc@YOUR_IP

# If SSH also fails, reboot from console:
# Oracle Cloud Console → Instance → More Actions → Reboot
```

---

### Issue 6.2: Out of Resources (Free Tier Limits)

**Check resource usage:**
1. Oracle Cloud Console → Billing → Usage
2. View compute hours used

**Solutions:**
- Use lighter desktop (LXDE/TWM)
- Stop VNC when not using: `sudo systemctl stop vncserver@1.service`
- Delete unnecessary files: `sudo dnf clean all`

---

## 🔧 Advanced Troubleshooting

### Clean Complete Reinstall

If nothing works, complete clean reinstall:

```bash
# 1. Stop and disable VNC
sudo systemctl stop vncserver@1.service
sudo systemctl disable vncserver@1.service

# 2. Remove VNC config
rm -rf ~/.vnc

# 3. Remove systemd service
sudo rm -f /etc/systemd/system/vncserver@.service
sudo systemctl daemon-reload

# 4. Reinstall VNC server
sudo dnf reinstall -y tigervnc-server

# 5. Re-run Oracle Desktop installer
cd ~/oracle-desktop
sudo ./oracle-desktop-setup.sh
```

---

### Manual VNC Start (Debugging)

```bash
# Stop systemd service
sudo systemctl stop vncserver@1.service

# Start VNC manually to see errors
vncserver :1 -geometry 1920x1080 -depth 24 -localhost no

# Check output for errors
# View log:
cat ~/.vnc/*.log

# If works manually, systemd service is the issue
# If fails manually, xstartup or desktop is the issue
```

---

### Check All Logs

```bash
# VNC service logs
sudo journalctl -u vncserver@1.service -n 100

# VNC session logs
cat ~/.vnc/*.log

# System logs (X server)
sudo journalctl -n 100 | grep -i vnc

# Installation log
sudo cat /var/log/oracle-desktop-setup.log
```

---

## 🆘 Emergency Recovery

### If You Locked Yourself Out

**Can't SSH anymore:**
1. Oracle Cloud Console → Instance
2. Click "Console Connection"
3. Create console connection
4. Use browser-based console to access server
5. Fix issues from there

**Reset everything:**
```bash
# From console connection:
sudo systemctl stop vncserver@1.service
sudo firewall-cmd --remove-port=5901/tcp --permanent
sudo firewall-cmd --reload
rm -rf ~/.vnc
```

---

## 📊 Common Error Messages

| Error Message | Cause | Solution |
|---------------|-------|----------|
| "Connection refused" | Oracle firewall | Configure Security List |
| "Connection timeout" | Instance stopped | Start instance |
| "Authentication failed" | Wrong password | Reset: `vncpasswd` |
| "No route to host" | Wrong IP | Verify IP: `curl ifconfig.me` |
| "Display :1 already in use" | Stale process | `vncserver -kill :1` |
| "Cannot open display" | X server issue | `sudo dnf reinstall tigervnc-server` |
| "Desktop not starting" | Bad xstartup | Recreate xstartup file |
| "Grey screen" | TWM installed | Normal - right-click for menu |

---

## 🎯 Quick Diagnostic Commands

Run these to gather information:

```bash
# Complete system check
sudo vnc-healthcheck

# Service status
sudo vnc-status

# View all logs
sudo vnc-logs

# Auto-fix common issues
sudo vnc-heal

# Check which desktop installed
cat /tmp/installed_desktop.txt

# Check VNC is listening
sudo ss -tlnp | grep 5901

# Check firewall
sudo firewall-cmd --list-all

# View installation log
sudo cat /var/log/oracle-desktop-setup.log | tail -100
```

---

## 💡 Prevention Tips

1. **Always configure Oracle Cloud Security List first**
2. **Save VNC password in password manager**
3. **Run `vnc-healthcheck` after making changes**
4. **Keep system updated:** `sudo dnf update -y`
5. **Monitor resources:** `free -h` and `df -h`
6. **Backup config:** `tar -czf vnc-backup.tar.gz ~/.vnc/`

---

**Still having issues? Run:**
```bash
sudo vnc-healthcheck
sudo vnc-heal
sudo vnc-logs
```

**And review the README.md for more detailed information!**
