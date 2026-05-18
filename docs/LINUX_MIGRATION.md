# Linux Migration Guide

Complete guide for migrating Linux hosts (Pop!_OS, Kali, Ubuntu, Debian) to the dotfiles system.

## Prerequisites

- SSH access to the target machine
- sudo privileges on the target machine
- Git installed on the target machine

## Quick Migration (TL;DR)

```bash
# On the target machine:

# 1. Clone dotfiles
git clone https://github.com/loidolt/dotfiles.git ~/dotfiles

# 2. Install Homebrew (Linuxbrew)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# 3. Install zsh via system package manager (NOT brew - avoids PATH/terminfo issues)
sudo apt install -y zsh

# 4. Install stow and essential packages via brew
brew install stow tmux starship eza bat fd ripgrep zoxide fzf git gh delta direnv jq yq httpie curl wget htop tree tlrc navi dust duf procs lazygit

# 5. Backup and remove conflicting configs
mv ~/.config/navi ~/.config/navi.backup 2>/dev/null || true

# 6. Stow all configs
cd ~/dotfiles/stow
for pkg in */; do stow -R -t "$HOME" "${pkg%/}"; done

# 7. Set system zsh as login shell
chsh -s $(which zsh)

# 8. Create host-specific directory (optional)
mkdir -p ~/dotfiles/hosts/$(hostname)
```

---

## Detailed Migration Steps

### Step 1: Clone the Dotfiles Repository

```bash
# Using HTTPS (works without SSH keys configured)
git clone https://github.com/loidolt/dotfiles.git ~/dotfiles

# Or using SSH (if keys are configured)
git clone git@github.com:loidolt/dotfiles.git ~/dotfiles
```

### Step 2: Install Homebrew (Linuxbrew)

Homebrew provides consistent, up-to-date packages across all Linux distributions.

```bash
# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Add to current session
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# Verify installation
brew --version
```

**Note:** The `.zshrc` automatically adds Linuxbrew to PATH, so this only needs to be done for the initial session.

### Step 3: Install Zsh (System Package Manager)

**Important:** Install zsh via your system's package manager, NOT brew. This avoids PATH initialization and terminfo issues.

```bash
# Debian/Ubuntu/Pop!_OS
sudo apt install -y zsh

# Fedora/RHEL
sudo dnf install -y zsh

# Arch
sudo pacman -S --noconfirm zsh
```

### Step 4: Install Stow and Packages (Homebrew)

```bash
# Install stow first
brew install stow

# Install all common packages (note: zsh is NOT included)
brew install \
  tmux starship \
  eza bat fd ripgrep zoxide fzf \
  git lazygit gh delta \
  direnv jq yq \
  httpie curl wget \
  htop tree tlrc navi dust duf procs
```

**Package Categories:**
- **Shell & Terminal:** tmux, starship (zsh via system)
- **Modern CLI replacements:** eza (ls), bat (cat), fd (find), ripgrep (grep), zoxide (cd), fzf (fuzzy finder)
- **Git tools:** git, lazygit, gh (GitHub CLI), delta (diff viewer)
- **Development:** direnv, jq, yq
- **Network:** httpie, curl, wget
- **System utilities:** htop, tree, tlrc (tldr), navi, dust, duf, procs

### Step 5: Backup Existing Configurations

Check for and backup any existing configs that would conflict with stow:

```bash
# Check what exists
ls -la ~/.zshrc ~/.gitconfig ~/.tmux.conf ~/.config/starship.toml 2>/dev/null

# Backup any existing configs
for config in ~/.zshrc ~/.gitconfig ~/.tmux.conf ~/.fzf.zsh; do
  [ -f "$config" ] && [ ! -L "$config" ] && mv "$config" "${config}.backup-$(date +%Y%m%d)"
done

for config in ~/.config/navi ~/.config/direnv ~/.config/starship.toml ~/.config/ghostty ~/.config/opencode ~/.config/claude; do
  [ -e "$config" ] && [ ! -L "$config" ] && mv "$config" "${config}.backup-$(date +%Y%m%d)"
done
```

### Step 6: Stow All Configurations

```bash
cd ~/dotfiles/stow

# Stow all packages
for package in */; do
  package=${package%/}
  echo "Stowing $package..."
  stow -R -t "$HOME" "$package"
done

# Or use the stow-all script
cd ~/dotfiles
./stow-all.sh
```

**Verify symlinks:**
```bash
ls -la ~/.zshrc ~/.gitconfig ~/.tmux.conf ~/.config/starship.toml
```

All should be symlinks pointing to `~/dotfiles/stow/...`

### Step 7: Set System ZSH as Login Shell

```bash
# Change login shell to system zsh
chsh -s $(which zsh)

# Verify
grep $USER /etc/passwd | cut -d: -f7
# Should show: /bin/zsh or /usr/bin/zsh
```

### Step 8: Create Host-Specific Configuration (Optional)

For machine-specific settings:

```bash
# Create host directory
mkdir -p ~/dotfiles/hosts/$(hostname)

# Create host.sh
cat > ~/dotfiles/hosts/$(hostname)/host.sh << 'EOF'
#!/usr/bin/env bash
# Host-specific configuration for $(hostname)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Copy host-specific SSH config if it exists
if [ -f "$SCRIPT_DIR/ssh-config" ]; then
    cp "$SCRIPT_DIR/ssh-config" ~/.ssh/config.local
    chmod 600 ~/.ssh/config.local
fi

# Add Homebrew to PATH (Linux)
if [ -d "/home/linuxbrew/.linuxbrew" ]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# Add any host-specific configuration below
EOF

# Create README
cat > ~/dotfiles/hosts/$(hostname)/README.md << EOF
# $(hostname)

Host-specific configuration.

## Setup Notes

- OS: $(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)
- Package Manager: Linuxbrew

## Files

- \`host.sh\` - Shell configuration sourced by \`.zshrc\`
- \`ssh-config\` - SSH configuration (optional, copied to \`~/.ssh/config.local\`)
EOF

# Commit and push (if you want to save it)
cd ~/dotfiles
git add hosts/$(hostname)
git commit -m "Add host configuration for $(hostname)"
git push
```

---

## Migrating from Brew ZSH to System ZSH

If your host is currently using Homebrew's zsh (`/home/linuxbrew/.linuxbrew/bin/zsh`), follow these steps to migrate to system zsh. This fixes PATH initialization and terminfo issues (e.g., tmux "open terminal failed" errors).

### Step 1: Install System ZSH

```bash
# Debian/Ubuntu/Pop!_OS
sudo apt install -y zsh

# Fedora/RHEL
sudo dnf install -y zsh

# Arch
sudo pacman -S --noconfirm zsh
```

### Step 2: Change Login Shell

```bash
# Verify system zsh path
which zsh
# Should show: /bin/zsh or /usr/bin/zsh

# Add to /etc/shells if needed
which zsh | sudo tee -a /etc/shells

# Change login shell
chsh -s $(which zsh)
```

### Step 3: Remove Brew ZSH from /etc/shells

```bash
# Remove brew zsh from allowed shells
sudo sed -i '/linuxbrew.*zsh/d' /etc/shells
```

### Step 4: Update Dotfiles and Re-stow

```bash
cd ~/dotfiles
git pull

# Re-stow zsh config to ensure .zshenv is linked
cd stow
stow -R -t "$HOME" zsh
```

### Step 5: Verify

```bash
# Log out and back in, then verify:
echo $SHELL
# Expected: /bin/zsh or /usr/bin/zsh

which zsh
# Expected: /bin/zsh or /usr/bin/zsh

# Test tmux
tmux
```

### Step 6: (Optional) Uninstall Brew ZSH

```bash
brew uninstall zsh
```

---

## Cleaning Up Nix (If Previously Installed)

If the machine previously used Nix, follow these steps to completely remove it:

### Step 1: Remove User Nix Files

```bash
rm -rf ~/.nix-profile ~/.nix-defexpr ~/.config/nix ~/.local/state/nix
```

### Step 2: Remove System Nix Installation (requires sudo)

```bash
# Remove nix entry from /etc/shells
sudo sed -i '/nix/d' /etc/shells

# Remove nix installation
sudo rm -rf /nix /etc/nix

# Remove nix profile script
sudo rm -f /etc/profile.d/nix.sh

# Remove nix lines from bash.bashrc
sudo sed -i '/nix/d' /etc/bash.bashrc

# Remove nixbld users and group (optional)
for i in $(seq 1 32); do sudo userdel nixbld$i 2>/dev/null || true; done
sudo groupdel nixbld 2>/dev/null || true
```

### Step 3: Verify Cleanup

```bash
# Check no nix directories remain
ls -la /nix /etc/nix 2>&1

# Check no nix in shells
grep nix /etc/shells

# Check no nix references in configs
grep -r nix /etc/profile /etc/profile.d/ /etc/bash.bashrc 2>/dev/null
```

---

## Distribution-Specific Notes

### Pop!_OS / Ubuntu / Debian

```bash
# Install build dependencies for Homebrew (if needed)
sudo apt-get update
sudo apt-get install -y build-essential procps curl file git
```

### Kali Linux

```bash
# Kali is Debian-based, same as Ubuntu
sudo apt-get update
sudo apt-get install -y build-essential procps curl file git
```

### Fedora / RHEL

```bash
# Install build dependencies
sudo dnf groupinstall -y "Development Tools"
sudo dnf install -y procps-ng curl file git
```

### Arch Linux

```bash
# Install build dependencies
sudo pacman -S --noconfirm base-devel procps-ng curl file git
```

---

## Headless/Remote Desktop Setup (RustDesk)

If you need to access the machine remotely via RustDesk without a physical display attached, you'll need to configure a virtual display using the X11 dummy driver.

### Step 1: Install the Dummy Video Driver

```bash
sudo apt-get install xserver-xorg-video-dummy
```

### Step 2: Create the Headless X11 Configuration

```bash
sudo tee /etc/X11/xorg.conf.d/10-headless.conf << 'EOF'
Section "Device"
    Identifier "Dummy"
    Driver "dummy"
    VideoRam 256000
EndSection

Section "Screen"
    Identifier "Screen0"
    Device "Dummy"
    DefaultDepth 24
    SubSection "Display"
        Depth 24
        Modes "1920x1080"
    EndSubSection
EndSection
EOF
```

### Step 3: Restart the Display Manager

```bash
# For GNOME (Pop!_OS, Ubuntu)
sudo systemctl restart gdm3

# For LightDM (Kali, some Ubuntu variants)
sudo systemctl restart lightdm
```

### Step 4: Verify

After restarting, you should be able to connect via RustDesk even without a physical monitor attached. The virtual display will present a 1920x1080 resolution.

**Note:** If you later attach a physical monitor and want to use it instead, you may need to remove or rename the headless config:

```bash
sudo mv /etc/X11/xorg.conf.d/10-headless.conf /etc/X11/xorg.conf.d/10-headless.conf.disabled
sudo systemctl restart gdm3
```

---

## Troubleshooting

### Homebrew not in PATH

If `brew` command is not found after installation:

```bash
# Add to current session
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# Or source the zshrc
source ~/.zshrc
```

### Stow conflicts

If stow reports conflicts:

```bash
# Check what's conflicting
stow -n -v package_name 2>&1 | grep -i conflict

# Backup the conflicting file
mv ~/.config/conflicting_file ~/.config/conflicting_file.backup

# Try again
stow -R -t "$HOME" package_name
```

### Shell not changing

If `chsh` doesn't work:

```bash
# Verify zsh is in /etc/shells
cat /etc/shells | grep zsh

# If system zsh is not listed, add it
which zsh | sudo tee -a /etc/shells

# Try chsh again
chsh -s $(which zsh)
```

### SSH key not working for GitHub

Use HTTPS instead of SSH for the remote:

```bash
cd ~/dotfiles
git remote set-url origin https://github.com/loidolt/dotfiles.git
```

---

## Post-Migration Verification

Run these commands to verify everything is working:

```bash
# Check shell (should be system zsh, NOT brew zsh)
echo $SHELL
# Expected: /bin/zsh or /usr/bin/zsh

# Check zsh is system version
which zsh
# Expected: /bin/zsh or /usr/bin/zsh (NOT /home/linuxbrew/.linuxbrew/bin/zsh)

# Check key tools (these should be from brew)
which brew starship eza bat rg fzf git gh
# All should point to /home/linuxbrew/.linuxbrew/bin/

# Check symlinks
ls -la ~/.zshrc ~/.zshenv ~/.gitconfig
# All should be symlinks to ~/dotfiles/stow/...

# Test starship prompt
starship --version

# Test tmux
tmux new -d -s test && echo "tmux works" && tmux kill-session -t test
```

---

## Updating After Migration

```bash
# Update dotfiles
cd ~/dotfiles
git pull
./stow-all.sh

# Update packages
brew update && brew upgrade
```
