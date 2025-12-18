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

# 3. Install stow and essential packages
brew install stow zsh tmux starship eza bat fd ripgrep zoxide fzf git gh delta direnv jq yq httpie curl wget htop tree tlrc navi dust duf procs neovim lazygit

# 4. Backup and remove conflicting configs
mv ~/.config/nvim ~/.config/nvim.backup 2>/dev/null || true
mv ~/.config/navi ~/.config/navi.backup 2>/dev/null || true

# 5. Stow all configs
cd ~/dotfiles/stow
for pkg in */; do stow -R -t "$HOME" "${pkg%/}"; done

# 6. Set Homebrew zsh as login shell
echo '/home/linuxbrew/.linuxbrew/bin/zsh' | sudo tee -a /etc/shells
chsh -s /home/linuxbrew/.linuxbrew/bin/zsh

# 7. Create host-specific directory (optional)
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

### Step 3: Install Stow and Packages

```bash
# Install stow first
brew install stow

# Install all common packages
brew install \
  zsh tmux starship \
  eza bat fd ripgrep zoxide fzf \
  git lazygit gh delta \
  neovim direnv jq yq \
  httpie curl wget \
  htop tree tlrc navi dust duf procs
```

**Package Categories:**
- **Shell & Terminal:** zsh, tmux, starship
- **Modern CLI replacements:** eza (ls), bat (cat), fd (find), ripgrep (grep), zoxide (cd), fzf (fuzzy finder)
- **Git tools:** git, lazygit, gh (GitHub CLI), delta (diff viewer)
- **Editors:** neovim
- **Development:** direnv, jq, yq
- **Network:** httpie, curl, wget
- **System utilities:** htop, tree, tlrc (tldr), navi, dust, duf, procs

### Step 4: Backup Existing Configurations

Check for and backup any existing configs that would conflict with stow:

```bash
# Check what exists
ls -la ~/.zshrc ~/.gitconfig ~/.tmux.conf ~/.config/nvim ~/.config/starship.toml 2>/dev/null

# Backup any existing configs
for config in ~/.zshrc ~/.gitconfig ~/.tmux.conf ~/.fzf.zsh; do
  [ -f "$config" ] && [ ! -L "$config" ] && mv "$config" "${config}.backup-$(date +%Y%m%d)"
done

for config in ~/.config/nvim ~/.config/navi ~/.config/direnv ~/.config/starship.toml ~/.config/ghostty ~/.config/opencode ~/.config/claude; do
  [ -e "$config" ] && [ ! -L "$config" ] && mv "$config" "${config}.backup-$(date +%Y%m%d)"
done
```

### Step 5: Stow All Configurations

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
ls -la ~/.zshrc ~/.gitconfig ~/.tmux.conf ~/.config/nvim ~/.config/starship.toml
```

All should be symlinks pointing to `~/dotfiles/stow/...`

### Step 6: Set Homebrew ZSH as Login Shell

```bash
# Add Homebrew zsh to allowed shells
echo '/home/linuxbrew/.linuxbrew/bin/zsh' | sudo tee -a /etc/shells

# Change login shell
chsh -s /home/linuxbrew/.linuxbrew/bin/zsh

# Verify
grep $USER /etc/passwd | cut -d: -f7
# Should show: /home/linuxbrew/.linuxbrew/bin/zsh
```

### Step 7: Create Host-Specific Configuration (Optional)

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

# If not, add it
echo '/home/linuxbrew/.linuxbrew/bin/zsh' | sudo tee -a /etc/shells

# Try chsh again
chsh -s /home/linuxbrew/.linuxbrew/bin/zsh
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
# Check shell
echo $SHELL
# Expected: /home/linuxbrew/.linuxbrew/bin/zsh

# Check key tools
which brew starship nvim eza bat rg fzf git gh
# All should point to /home/linuxbrew/.linuxbrew/bin/

# Check symlinks
ls -la ~/.zshrc ~/.gitconfig ~/.config/nvim
# All should be symlinks to ~/dotfiles/stow/...

# Test starship prompt
starship --version

# Test neovim
nvim --version
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
