# Troubleshooting Guide

## Home Manager Warnings

### "Git tree is dirty"

**Cause:** You have uncommitted changes in your dotfiles repository.

**Fix:**
```bash
cd ~/Documents/GitHub/dotfiles
git add .
git commit -m "Your commit message"
```

**Why it matters:** Nix flakes work best with committed code to ensure reproducibility.

---

### "Trusted user" warnings

**Full warnings:**
```
warning: ignoring the client-specified setting 'auto-optimise-store'
warning: ignoring untrusted substituter 'https://nix-community.cachix.org'
warning: ignoring the client-specified setting 'trusted-public-keys'
```

**Cause:** Your user is not in the Nix daemon's trusted users list.

**Fix:**

1. **Automated (recommended):**
   ```bash
   /tmp/fix-nix-warnings.sh
   ```

2. **Manual:**
   ```bash
   # Edit Nix config
   sudo nano /etc/nix/nix.conf
   
   # Add this line:
   trusted-users = root chrisloidolt
   
   # Save and exit (Ctrl+O, Enter, Ctrl+X)
   
   # Restart Nix daemon
   sudo launchctl kickstart -k system/org.nixos.nix-daemon
   ```

**Impact:** Cosmetic only. Everything works fine, you just see warnings.

**Benefits of fixing:**
- Clean output
- Can use custom binary caches (faster builds)
- Can enable store optimization
- Can use additional trusted public keys

---

### "215 unread news items"

**Cause:** Home Manager has accumulated news/changelog items.

**Fix (optional):**
```bash
# Read the news
home-manager news

# Mark all as read without reading
home-manager news --show > /dev/null
```

**Impact:** None - purely informational.

---

## Common Issues

### Command not found: hm

**Cause:** Shell aliases haven't been loaded yet.

**Fix:**
```bash
# Reload shell
exec zsh

# Or source directly
source ~/.zshrc

# Then try
hm
```

---

### devbox: command not found

**Cause:** Home Manager hasn't been applied yet.

**Fix:**
```bash
cd ~/Documents/GitHub/dotfiles
home-manager switch --flake .#chrisloidolt
```

---

### "No such file or directory: ~/.config/home-manager"

**Cause:** Using wrong path to home-manager configuration.

**Fix:** Use one of these commands instead:
```bash
# Use the alias (after reloading shell)
hm

# Or full path
home-manager switch --flake ~/Documents/GitHub/dotfiles#chrisloidolt

# Or from dotfiles directory
cd ~/Documents/GitHub/dotfiles
home-manager switch --flake .#chrisloidolt
```

---

## Devbox Issues

### "Package not found"

**Cause:** Package name doesn't exist or is spelled incorrectly.

**Fix:**
```bash
# Search for packages
devbox search <package-name>

# Or search on nixpkgs
# https://search.nixos.org/packages
```

---

### Changes to devbox.json not applied

**Cause:** Need to reload the environment.

**Fix:**
```bash
# Exit and re-enter devbox shell
exit
devbox shell

# Or update packages
devbox update
```

---

### Conflicting package versions

**Cause:** Different devbox environments trying to use same resources.

**Fix:**
```bash
# Each project has isolated environment
# Just use devbox shell in the project directory

cd /path/to/project
devbox shell
```

---

## Nix Issues

### Disk space running low

**Cause:** Nix store accumulates old generations.

**Fix:**
```bash
# Remove old generations
nix-collect-garbage -d

# Or use home-manager
home-manager expire-generations "-7 days"
```

---

### Build fails with "cannot build derivation"

**Cause:** Network issues or corrupted downloads.

**Fix:**
```bash
# Clear the Nix store cache and retry
nix-store --verify --check-contents --repair

# Or force a rebuild
home-manager switch --flake ~/Documents/GitHub/dotfiles#chrisloidolt --refresh
```

---

## Getting Help

1. **Check logs:**
   ```bash
   # Home Manager logs
   journalctl --user -u home-manager-*
   
   # Nix daemon logs (on macOS)
   tail -f /var/log/nix-daemon.log
   ```

2. **Verbose output:**
   ```bash
   home-manager switch --flake ~/Documents/GitHub/dotfiles#chrisloidolt --verbose
   ```

3. **Documentation:**
   - [Home Manager Manual](https://nix-community.github.io/home-manager/)
   - [Nix Manual](https://nixos.org/manual/nix/stable/)
   - [Devbox Docs](https://www.jetify.com/devbox/docs/)

4. **This repository:**
   - [Package Management Guide](./PACKAGE_MANAGEMENT_GUIDE.md)
   - [Quick Reference](./QUICK_REFERENCE.md)
