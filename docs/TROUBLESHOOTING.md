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
nix build .#homeConfigurations.chrisloidolt.activationPackage --show-trace
```

---

### Programs not found after rebuild

**Cause:** Shell PATH not updated.

**Fix:**
```bash
# Restart your shell
exec zsh

# Or check PATH includes nix-profile
echo $PATH | grep nix-profile
```

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
home-manager switch --flake .#chrisloidolt --refresh
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
   home-manager switch --flake .#chrisloidolt --verbose
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
