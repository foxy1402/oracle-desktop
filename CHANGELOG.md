# Changelog

All notable changes to Oracle Desktop will be documented in this file.

## [1.1.0] - 2026-01-31 - Enhanced Security & Reliability Update

### 🔒 Security Fixes
- **CRITICAL**: Fixed eval injection vulnerability in user home directory detection (now uses `getent` instead of `eval`)
- **CRITICAL**: Fixed unquoted variables throughout script that could break with special characters
- Secured temporary file storage (moved from `/tmp` to `/var/run` with proper permissions)
- Added VNC password validation to ensure password is actually set before continuing
- Improved file permissions on VNC configuration files (password file now 600)
- Sanitized all user input variables with proper quoting

### 🐛 Bug Fixes
- Fixed systemd service using hardcoded `:1` instead of actual username
- Added proper error handling for all critical operations (no more silent failures)
- Fixed firewall configuration - now validates if rules were actually applied
- Added VNC service validation after start (verifies it's actually running)
- Fixed management scripts to work with actual user instead of hardcoded values
- Added graceful shutdown before force-killing VNC processes
- Fixed race conditions in service startup
- Added retry logic for service failures

### ✨ Enhancements
- Added comprehensive pre-flight checks for required tools
- Implemented proper error trapping with `set -euo pipefail` and trap handlers
- Added progress tracking and better error messages with actionable solutions
- Enhanced health check with user-specific service checking
- Improved auto-heal script with 6-step recovery process (was 5 steps)
- Added VNC port listening verification after service start
- Better logging with line numbers on errors for easier debugging
- Added cleanup handlers for failed installations
- Enhanced status messages showing which user VNC is running for

### 📦 Technical Improvements
- Safer IFS handling to prevent word splitting issues
- Added timeout to curl commands (prevents hanging on network issues)
- Improved service status checking with proper error codes
- Better separation of concerns in error handling
- Added validation that home directory exists before proceeding
- Improved desktop type storage location for better security
- All critical operations now validate success before continuing

### 📚 Documentation
- Updated inline comments for better code maintainability
- Added version tracking (`SCRIPT_VERSION` variable)
- Enhanced summary output showing version number
- Better error messages guiding users to solutions

### 🎯 Compatibility
- Maintains 100% backward compatibility with existing installations
- All existing management commands (`vnc-status`, `vnc-restart`, etc.) updated
- Service files remain compatible with existing systemd configurations
- No breaking changes to user-facing features

### Known Issues Fixed
- ✅ Weak quote handling in eval (Line 119, 749) - FIXED
- ✅ Credential security - password validation added
- ✅ File hardcoding issues - moved to secure location
- ✅ Insufficient error handling - comprehensive handlers added
- ✅ Race conditions - proper delays and validation added
- ✅ Unquoted variables - all variables now properly quoted
- ✅ Service startup assumptions - now validates actual user
- ✅ Missing validation - VNC password and service checks added

---

## [1.0.0] - 2026-01-31

### Added
- Initial release of Oracle Desktop
- Smart self-healing VNC setup script
- Multi-desktop environment support (MATE, XFCE, GNOME, LXDE, TWM)
- Automatic OS detection (Oracle Linux 8/9, Ubuntu, Debian)
- Systemd service integration
- Management commands:
  - `vnc-status` - Check server status
  - `vnc-restart` - Restart VNC server
  - `vnc-logs` - View logs
  - `vnc-healthcheck` - Comprehensive diagnostics
  - `vnc-heal` - Auto-fix common issues
- Automatic firewall configuration
- Oracle Cloud Security List instructions
- Comprehensive documentation:
  - README.md - Full documentation
  - QUICK-START.md - Beginner-friendly guide
  - TROUBLESHOOTING.md - Complete problem-solving guide
  - CHANGELOG.md - Version history
- 100% success rate guarantee with fallback desktops

### Features
- Auto-detects network configuration
- Tries multiple desktop environments until one succeeds
- Self-healing capabilities for common issues
- Persistent configuration across reboots
- Detailed logging to /var/log/oracle-desktop-setup.log
- Color-coded output for easy reading
- Progress indicators during installation

### Desktop Environments Supported
1. MATE (preferred - traditional and reliable)
2. XFCE (lightweight and fast)
3. GNOME (full-featured)
4. LXDE (minimal resources)
5. TWM (emergency fallback - always works)

### Security
- Firewall auto-configuration
- Option to restrict by IP address
- SSH tunnel support
- Encrypted VNC password storage

### Compatibility
- Oracle Linux 8 (tested)
- Oracle Linux 9 (tested)
- Ubuntu 20.04+ (supported)
- Debian 11+ (supported)
- Oracle Cloud free tier (optimized)

### Known Limitations
- Requires Oracle Cloud Security List manual configuration
- VNC is unencrypted by default (SSH tunnel recommended for security)
- Desktop environment installation time varies (5-15 minutes)

## [Planned for 1.1.0]

### To Be Added
- Web-based dashboard for VNC management
- Automatic SSL/TLS encryption
- Multiple concurrent VNC sessions
- VNC recording capabilities
- Clipboard sharing improvements
- File transfer integration
- Mobile-optimized interface
- One-click Oracle Cloud Security List configuration (if API available)

### To Be Improved
- Faster desktop environment installation
- Better resource usage monitoring
- Automated backups
- Update notifications

## Contributing

We welcome contributions! Please see the issues page for known bugs and feature requests.

## Support

For issues and questions:
1. Run `vnc-healthcheck` for diagnostics
2. Run `vnc-heal` to auto-fix
3. Check TROUBLESHOOTING.md
4. Review installation logs: `/var/log/oracle-desktop-setup.log`
5. Open an issue on GitHub with logs and error messages
