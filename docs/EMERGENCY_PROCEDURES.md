# Emergency Procedures & Troubleshooting

**When things go wrong, don't panic!** Nix is designed to be recoverable.

---

## Quick Recovery Commands

```bash
# NixOS: Boot previous generation
# 1. Reboot
# 2. At GRUB menu, select previous generation
# 3. Boot into working system

# NixOS: Rollback to previous configuration
sudo nixos-rebuild switch --rollback

# Home Manager: List generations
home-manager generations

# Home Manager: Activate previous generation
/nix/store/HASH-home-manager-generation/activate

# macOS: Rollback darwin configuration
darwin-rebuild switch --rollback
```

---

## Table of Contents

- [Terminal Won't Start](#terminal-wont-start)
- [Home Manager Breaks Shell](#home-manager-breaks-shell)
- [Neovim Won't Load](#neovim-wont-load)
- [NixOS Won't Boot](#nixos-wont-boot)
- [Build Failures](#build-failures)
- [Out of Disk Space](#out-of-disk-space)
- [Rollback Procedures](#rollback-procedures)
- [Complete System Restore](#complete-system-restore)

---

## Terminal Won't Start

### Symptoms
- Terminal application won't open
- Terminal crashes immediately
- Black screen then closes

### Immediate Fix

**macOS:**
1. Open Terminal from Spotlight (Cmd+Space, type "Terminal")
2. If that fails, use Activity Monitor to kill any stuck terminal processes
3. Try opening Terminal.app from `/Applications/Utilities/`

**Alternative Shell:**
```bash
# If zsh is broken, use bash temporarily
bash

# Or try safe mode
/bin/sh
```

### Recover

```bash
# Check what shell is set
echo $SHELL

# If it's broken, rollback Home Manager
home-manager generations

# Activate previous generation (copy path from above)
/nix/store/PREVIOUS-GEN-HASH/activate

# Or rebuild with last known good config
cd ~/dotfiles
git log --oneline  # Find last working commit
git checkout HASH
home-manager switch --flake .
```

---

## Home Manager Breaks Shell

### Symptoms
- Shell starts but looks wrong
- No prompt appears
- Aliases don't work
- Programs not found

### Diagnosis

```bash
# Check which shell you're in
echo $SHELL

# Check if it's from Nix
which zsh

# Check PATH
echo $PATH | tr ':' '\n'

# Should see /nix/store paths
```

### Fix

**Option 1: Rollback Home Manager**
```bash
# List generations
home-manager generations

# You'll see output like:
# 2024-01-15 10:30:00 : id 1 -> /nix/store/...-home-manager-generation
# 2024-01-15 09:00:00 : id 2 -> /nix/store/...-home-manager-generation

# Activate the previous one (id 2 in this example)
/nix/store/...-home-manager-generation/activate

# Close and reopen terminal
```

**Option 2: Fix and Rebuild**
```bash
cd ~/dotfiles

# Check what changed
git log --oneline -5
git diff HEAD~1 home/programs/zsh.nix

# Fix the issue
nvim home/programs/zsh.nix

# Test build before activating
nix build .#homeConfigurations.YOUR_USERNAME.activationPackage

# If successful, activate
home-manager switch --flake .
```

**Option 3: Use Old Shell Temporarily**
```bash
# Switch to bash
chsh -s /bin/bash

# Log out and back in
# Now you can fix Home Manager without shell breaking
```

---

## Neovim Won't Load

### Symptoms
- Neovim won't start
- Neovim starts but plugins missing
- Error messages about config

### Diagnosis

```bash
# Check if neovim is installed
which nvim

# Try starting with verbose output
nvim --version
nvim +checkhealth

# Check symlink
ls -la ~/.config/nvim

# Should point to ~/dotfiles/configs/neovim
```

### Fix

**If symlink is broken:**
```bash
# Remove broken symlink
rm ~/.config/nvim

# Recreate manually
ln -s ~/dotfiles/configs/neovim ~/.config/nvim

# Or rebuild Home Manager
home-manager switch --flake ~/dotfiles
```

**If plugins won't load:**
```bash
# Lazy.nvim usually auto-installs on first run
# Force reinstall
nvim
# Then in nvim: :Lazy sync

# If that fails, clear lazy cache
rm -rf ~/.local/share/nvim/lazy
nvim  # Will reinstall
```

**If config has errors:**
```bash
# Use vanilla neovim temporarily
nvim -u NONE file.txt

# Check error log
cat ~/.local/state/nvim/log

# Test config syntax
nvim --headless -c "lua print('Config OK')" -c quit
```

---

## NixOS Won't Boot

### Symptoms
- System won't boot after rebuild
- Kernel panic
- Black screen
- Stuck at login screen

### Immediate Recovery

1. **Reboot the machine**

2. **At GRUB menu:**
   - You'll see multiple "NixOS" entries
   - Each is a previous generation
   - Select the one BEFORE your latest change
   - Press Enter to boot

3. **Once booted into old generation:**

```bash
# You're now in a working system
# Check what generations exist
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system

# Example output:
#  45   2024-01-15 10:30:00
#  46   2024-01-15 11:00:00 (current)

# Generation 45 is what you booted into
# Generation 46 is the broken one

# Option A: Rollback to generation 45
sudo nixos-rebuild switch --rollback

# Option B: Fix the issue
cd ~/dotfiles
git log --oneline
# Find the commit that broke it
git diff HASH hosts/nixos-desktop/default.nix

# Fix the config
nvim hosts/nixos-desktop/default.nix

# Test build (won't activate)
nixos-rebuild build --flake .#desktop

# If build succeeds, activate
sudo nixos-rebuild switch --flake .#desktop
```

### Prevent Future Boot Issues

```bash
# Always test build before switch
nixos-rebuild build --flake .#desktop

# If build succeeds, then switch
sudo nixos-rebuild switch --flake .#desktop

# Keep multiple working generations
# Don't clean up generations too aggressively
```

---

## Build Failures

### Nix Build Errors

**"error: flake .... does not provide attribute ..."**

```bash
# Check flake outputs
nix flake show

# Verify the path
# Should see: homeConfigurations.YOUR_USERNAME
# Or: nixosConfigurations.desktop

# If missing, check flake.nix syntax
nix flake check

# Look for errors in flake.nix
```

**"error: infinite recursion encountered"**

Usually caused by circular imports:

```bash
# Check imports in home/default.nix
# Make sure you're not importing a file that imports itself

# Common mistake:
# home/default.nix imports home/default.nix
```

**"error: attribute 'X' missing"**

```bash
# Check if package exists
nix search nixpkgs PACKAGE_NAME

# Check spelling in packages.nix
# Common mistakes:
# - nodejs vs nodejs_20
# - python vs python311
# - neovim vs nvim
```

### Show Detailed Errors

```bash
# Build with full trace
nix build --show-trace .#homeConfigurations.USERNAME.activationPackage

# This will show exactly where the error is
```

### Syntax Errors in Nix Files

```bash
# Nix syntax is picky!
# Common mistakes:

# Missing semicolon
home.packages = [
  git
  curl  # <- Forgot semicolon at end of list
]

# Should be:
home.packages = [
  git
  curl
];  # <- Note the semicolon

# Missing comma in attribute set
{
  enable = true
  defaultEditor = true  # <- Missing comma
}

# Should be:
{
  enable = true;
  defaultEditor = true;
}
```

---

## Out of Disk Space

### Check Disk Usage

```bash
# Check Nix store size
du -sh /nix/store

# Check total disk usage
df -h
```

### Clean Up

```bash
# Delete old generations (older than 30 days)
sudo nix-collect-garbage --delete-older-than 30d

# Delete ALL old generations (keep only current)
# ⚠️ WARNING: Can't rollback after this!
sudo nix-collect-garbage -d

# Optimize store (remove duplicates)
nix-store --optimise

# Check space freed
df -h
```

### Emergency Cleanup

```bash
# If really out of space, manually delete old generations

# NixOS: List system generations
ls -la /nix/var/nix/profiles/

# Delete specific old generation
sudo nix-env --delete-generations 10 --profile /nix/var/nix/profiles/system

# Home Manager: List generations
ls -la ~/.local/state/nix/profiles/

# Delete old home-manager generations
rm ~/.local/state/nix/profiles/home-manager-*-link
# Keep the latest few!

# Then garbage collect
sudo nix-collect-garbage -d
```

---

## Rollback Procedures

### Home Manager Rollback

```bash
# Method 1: List and activate previous generation
home-manager generations

# Output shows:
# 2024-01-15 11:00 : id 1 -> /nix/store/abc-hm-gen
# 2024-01-15 10:00 : id 2 -> /nix/store/def-hm-gen

# Activate generation 2
/nix/store/def-hm-gen/activate

# Method 2: Rebuild from old commit
cd ~/dotfiles
git log --oneline
git checkout PREVIOUS_COMMIT
home-manager switch --flake .
git checkout nix-migration  # Return to latest
```

### NixOS Rollback

```bash
# Method 1: From GRUB (safest)
# 1. Reboot
# 2. Select old generation from GRUB menu
# 3. Boot

# Method 2: From running system
sudo nixos-rebuild switch --rollback

# Method 3: Specific generation
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system
sudo nix-env --switch-generation 45 --profile /nix/var/nix/profiles/system
sudo nixos-rebuild switch
```

### macOS (nix-darwin) Rollback

```bash
# Method 1: Rollback command
darwin-rebuild switch --rollback

# Method 2: From git history
cd ~/dotfiles
git log --oneline
git checkout PREVIOUS_COMMIT
darwin-rebuild switch --flake .
git checkout nix-migration
```

---

## Complete System Restore

### Complete Nix Uninstall

If you need to completely uninstall Nix:

```bash
# 1. Uninstall Home Manager
home-manager uninstall

# 2. Remove Nix (macOS)
sudo rm -rf /nix
sudo rm /etc/bashrc.backup-before-nix
sudo rm /etc/zshrc.backup-before-nix

# Edit /etc/zshrc and /etc/bashrc to remove Nix sections

# 3. Remove Nix configuration
rm -rf ~/.config/nix
rm -rf ~/.nix-*

# Linux:
sudo rm -rf /nix
# Remove Nix from /etc/profile or similar
```

### Partial Rollback (Keep Nix, Revert to Manual Config)

```bash
# Keep Nix installed but manually manage configs
cd ~/Documents/GitHub/dotfiles

# Uninstall Home Manager
home-manager uninstall

# Manually link configs if needed
ln -s ~/Documents/GitHub/dotfiles/configs/neovim ~/.config/nvim
ln -s ~/Documents/GitHub/dotfiles/configs/opencode ~/.config/opencode
```

---

## Getting Help

### Logs and Debug Info

```bash
# Home Manager logs
journalctl --user -xe | grep home-manager

# NixOS system logs
journalctl -xe

# Last activation log
cat /nix/var/log/nix/drvs/...
# (Look in this directory for recent .drv files)

# Nix daemon logs (macOS)
cat /var/log/nix-daemon.log

# Build output
# When a build fails, Nix shows the log path
# Read it for detailed error info
```

### Debug Nix Expression

```bash
# Use nix repl to test expressions
nix repl

# In repl:
:l <nixpkgs>
:l ~/dotfiles
# Now you can test expressions

# Example:
:l ~/dotfiles
outputs.homeConfigurations.chris
# Will show if this attribute exists
```

### Community Resources

- **NixOS Discourse:** https://discourse.nixos.org/
- **NixOS Wiki:** https://nixos.wiki/
- **Home Manager Manual:** https://nix-community.github.io/home-manager/
- **Search packages:** https://search.nixos.org/packages
- **Reddit:** r/NixOS
- **Matrix Chat:** #nix:nixos.org

### Create Minimal Reproduction

If asking for help online:

```bash
# Create a minimal flake that reproduces the issue
mkdir ~/debug-nix
cd ~/debug-nix

cat > flake.nix << 'EOF'
{
  description = "Minimal reproduction of issue";
  
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  
  outputs = { self, nixpkgs }: {
    # Your minimal failing config here
  };
}
EOF

# Try to build
nix build
# Share the error with the community
```

---

## Prevention Tips

### Best Practices to Avoid Emergencies

1. **Always commit before major changes**
   ```bash
   git add .
   git commit -m "Before trying X"
   ```

2. **Test builds before activating**
   ```bash
   # Test first
   nix build .#homeConfigurations.USERNAME.activationPackage
   
   # Then activate
   home-manager switch --flake .
   ```

3. **Keep multiple generations**
   ```bash
   # Don't clean up too aggressively
   # Keep at least 3-5 generations
   sudo nix-collect-garbage --delete-older-than 30d
   # NOT: sudo nix-collect-garbage -d
   ```

4. **Use version control**
   ```bash
   # Push changes frequently
   git push origin nix-migration
   
   # Even failed experiments can be useful
   git commit -m "WIP: Trying X (doesn't work yet)"
   ```

5. **Document changes in MIGRATION_LOG.md**
   - What you changed
   - Why you changed it
   - What happened

6. **Test in VM first**
   - For NixOS changes, test in VM before real hardware
   - VirtualBox or UTM is quick to set up

---

## Emergency Contact List

**Keep this accessible outside your computer:**

- GitHub repo URL: https://github.com/YOUR_USERNAME/dotfiles
- Backup branch: ansible-backup
- Last known working commit: [Write down after Phase 2]
- Your username: [Your username]
- Platform: macOS / NixOS / WSL

**Print this page or keep it on your phone!**

---

Remember: **Nix is designed to be safe**. You can almost always rollback or recover. The worst case is rebooting into an old generation or restoring from your git backup.
