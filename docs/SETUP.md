# Development Machine Setup Guide

Complete guide for setting up a new development machine using these dotfiles with Home Manager.

## Quick Start

### macOS Setup

```bash
# Clone this repository
git clone https://github.com/loidolt/dotfiles.git ~/Documents/GitHub/dotfiles
cd ~/Documents/GitHub/dotfiles

# Install Nix (if not already installed)
sh <(curl -L https://nixos.org/nix/install) --daemon

# Enable flakes
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf

# Restart your terminal, then activate Home Manager
nix run home-manager/master -- switch --flake .#chrisloidolt -b backup --impure

# Install fonts via Homebrew
brew install --cask font-fira-code-nerd-font font-jetbrains-mono-nerd-font font-meslo-lg-nerd-font

# Close and reopen your terminal
```

### Linux / WSL2 Setup

```bash
# Clone this repository
git clone https://github.com/loidolt/dotfiles.git ~/dotfiles
cd ~/dotfiles

# Install Nix (if not already installed)
sh <(curl -L https://nixos.org/nix/install) --daemon

# Enable flakes
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf

# Restart your terminal, then activate Home Manager
nix run home-manager/master -- switch --flake .#chrisloidolt-linux -b backup --impure

# Close and reopen your terminal
```

## What Gets Installed

### Core Packages
- **git, curl, wget** - Essential utilities
- **vim, neovim, tmux** - Terminal tools
- **btop, tree, jq** - System utilities

### Modern CLI Tools
- **ripgrep (rg)** - Fast grep alternative
- **fd** - Fast find alternative
- **bat** - Cat with syntax highlighting
- **fzf** - Fuzzy finder
- **eza** - Modern ls replacement
- **zoxide** - Smart directory jumping
- **delta** - Better git diffs
- **lazygit** - Terminal UI for git

### Languages & Runtimes
- **Node.js 20** (LTS)
- **Bun** - Fast JavaScript runtime
- **TypeScript**, **Prettier**, **ESLint**
- **Devbox** - Per-project environments

### Programs Configured
- **Neovim** with LSP servers
- **Git** with delta integration
- **Tmux** with truecolor support
- **Zsh** with oh-my-zsh, autosuggestions, syntax highlighting
- **Starship** - Modern prompt
- **FZF** - Fuzzy finder with fd integration
- **Direnv** - Per-directory environments

### Fonts (Linux only via Nix, macOS via Homebrew)
- **FiraCode Nerd Font**
- **JetBrainsMono Nerd Font**
- **Meslo Nerd Font**

## Post-Installation Steps

### 1. Restart Terminal

```bash
# Or just close and reopen your terminal
source ~/.zshrc
```

### 2. Verify Installation

```bash
# Check programs point to Nix store
which nvim   # Should show /nix/store/...
which tmux
which git

# Test modern CLI tools
ls           # Should use eza with icons
bat README.md  # Should show syntax highlighting
```

### 3. Setup SSH Keys (Optional)

```bash
# Generate SSH key
ssh-keygen -t ed25519 -C "your-email@example.com"

# Add to ssh-agent
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519

# Add public key to GitHub
cat ~/.ssh/id_ed25519.pub
# Copy and paste to https://github.com/settings/keys
```

## Daily Usage

### Rebuild After Changes

```bash
hm   # Alias for home-manager switch --flake $DOTFILES#<config>
```

### Update All Packages

```bash
cd ~/Documents/GitHub/dotfiles  # or ~/dotfiles on Linux
nix flake update
hm
```

### Rollback to Previous Generation

```bash
# List all generations
home-manager generations

# Activate a previous generation
/nix/store/HASH-home-manager-generation/activate
```

### Clean Old Generations

```bash
# Delete generations older than 30 days
nix-collect-garbage --delete-older-than 30d

# Optimize Nix store (deduplicate)
nix-store --optimise
```

### Search for Packages

```bash
nix search nixpkgs <package-name>
# Or visit https://search.nixos.org/packages
```

## Customization

### Adding Packages

Edit `home/packages.nix`:

```nix
home.packages = with pkgs; [
  git
  your-new-package  # Add here
];
```

Then rebuild: `hm`

### Modifying Program Configs

Program configurations are in `home/programs/`:
- `zsh.nix` - Shell configuration
- `git.nix` - Git settings
- `neovim.nix` - Editor setup
- `tmux.nix` - Terminal multiplexer

## Troubleshooting

### Build Fails

```bash
# Check for syntax errors
nix flake check

# Build with full trace
nix build .#homeConfigurations.chrisloidolt.activationPackage --show-trace --impure
```

### Programs Not Found

```bash
# Check if in PATH
echo $PATH | grep nix-profile

# Rebuild
hm
```

### Rollback

```bash
home-manager generations
/nix/store/PREVIOUS-HASH-home-manager-generation/activate
```

## Security Notes

- Never commit API keys or secrets to git
- Use environment variables for sensitive data
- SSH private keys stay local (never copy between machines)
