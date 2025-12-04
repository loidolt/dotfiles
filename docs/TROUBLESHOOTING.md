# Troubleshooting Guide

## Quick Health Check

Run the health check script to diagnose common issues:

```bash
hm-health
# Or directly:
~/dotfiles/scripts/health-check.sh
```

This will check:
- Nix installation and daemon status
- PATH configuration (nix-profile, local bins)
- Shell configuration files
- External tools (opencode, claude)
- Key nix-managed tools

---

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
```bash
# Edit Nix config
sudo nano /etc/nix/nix.conf

# Add this line:
trusted-users = root chrisloidolt

# Save and exit (Ctrl+O, Enter, Ctrl+X)

# Restart Nix daemon (macOS)
sudo launchctl kickstart -k system/org.nixos.nix-daemon

# Restart Nix daemon (Linux)
sudo systemctl restart nix-daemon
```

**Impact:** Cosmetic only. Everything works fine, you just see warnings.

---

### "X unread news items"

**Cause:** Home Manager has accumulated news/changelog items.

**Fix (optional):**
```bash
# Read the news
home-manager news

# Mark all as read
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
```

---

### Build fails

**Cause:** Syntax error or missing dependency.

**Fix:**
```bash
# Check for errors
nix flake check

# Build with verbose output
nix build .#homeConfigurations.chrisloidolt.activationPackage --show-trace --impure
```

---

### Package conflict errors (e.g., wrangler vs prettier)

**Error:**
```
pkgs.buildEnv error: two given paths contain a conflicting subpath:
  `/nix/store/.../wrangler-.../lib/node_modules/prettier/LICENSE' and
  `/nix/store/.../prettier-.../lib/node_modules/prettier/LICENSE'
```

**Cause:** Two packages provide the same files. Common with Node.js tools where one package bundles another.

**Fix:**
```bash
# Remove the conflicting global package
# Example: wrangler includes prettier, so remove global prettier
# Edit home/packages.nix and remove nodePackages.prettier

# Then rebuild
hm
```

**Note:** If you need the removed tool globally:
- Install via npm: `npm install -g prettier`
- Add to project-specific devbox environments instead of global packages

---

### Programs not found after rebuild

**Cause:** Shell PATH not updated or nix-profile not in PATH.

**Fix:**
```bash
# Restart your shell
exec zsh

# Or check PATH includes nix-profile
echo $PATH | grep nix-profile

# If nix-profile is missing from PATH (common on Linux), source it manually:
source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh

# Then run hm to ensure .zprofile is created
hm
```

---

### External tools not found (opencode, claude)

**Cause:** These tools are installed via their own installers, not through nix/home-manager.

**Fix:**
```bash
# Install opencode
curl -fsSL https://opencode.ai/install | bash

# Install Claude CLI
curl -fsSL https://claude.ai/install | bash

# Ensure ~/.local/bin exists (needed for claude)
mkdir -p ~/.local/bin
```

**Note:** The PATH already includes `~/.local/bin` and `~/.opencode/bin`, so after installation these tools should work in new terminal sessions.

---

### Config changes not applied

**Cause:** Files need to be tracked by git, or you need to rebuild.

**Fix:**
```bash
# Check git status
git status

# Add files if needed
git add .

# Rebuild
hm
```

---

## Nix Issues

### Disk space running low

**Cause:** Nix store accumulates old generations.

**Fix:**
```bash
# Remove old generations (older than 30 days)
nix-collect-garbage --delete-older-than 30d

# Remove ALL old generations (be careful)
nix-collect-garbage -d

# Optimize store (deduplicate)
nix-store --optimise
```

---

### "cannot build derivation"

**Cause:** Network issues or corrupted downloads.

**Fix:**
```bash
# Verify and repair store
nix-store --verify --check-contents --repair

# Or force a fresh build
home-manager switch --flake .#chrisloidolt --refresh --impure
```

---

## Rollback

If something breaks badly:

```bash
# List all generations
home-manager generations

# Activate a previous (working) generation
/nix/store/HASH-home-manager-generation/activate

# Then fix the issue in your config before rebuilding
```

---

## Getting Help

1. **Verbose output:**
   ```bash
   home-manager switch --flake .#chrisloidolt --verbose --impure
   ```

2. **Check flake:**
   ```bash
   nix flake check
   nix flake show
   ```

3. **Documentation:**
   - [Home Manager Manual](https://nix-community.github.io/home-manager/)
   - [Nix Manual](https://nixos.org/manual/nix/stable/)
   - [Nix Package Search](https://search.nixos.org/packages)
