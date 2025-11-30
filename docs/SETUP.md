# Development Machine Setup Guide

Complete guide for setting up a new development machine using these dotfiles with Nix and Home Manager.

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
nix run home-manager/master -- switch --flake .#chrisloidolt -b backup

# Close and reopen your terminal
```

That's it! Everything is now configured.

## What Gets Installed

### Core Packages
- **git, curl, wget** - Essential utilities
- **vim, neovim, tmux** - Terminal tools
- **htop, tree, jq** - System utilities

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

### Programs
- **Neovim** v0.11.5 with LSP servers (Lua, Nix, TypeScript, etc.)
- **Git** v2.51.2 with delta integration
- **Tmux** v3.6 with truecolor support
- **Zsh** with oh-my-zsh, autosuggestions, syntax highlighting
- **Starship** - Modern prompt
- **FZF** - Fuzzy finder with fd integration
- **Direnv** - Per-directory environments with nix-direnv

### Fonts
- **FiraCode Nerd Font**
- **JetBrainsMono Nerd Font**
- **Meslo Nerd Font**

See [`home/packages.nix`](../home/packages.nix) for the complete list.

## Post-Installation Steps

### 1. Restart Terminal

```bash
# Reload shell configuration
source ~/.zshrc

# Or restart your terminal app
```

### 2. Verify Installation

Check that everything works:

```bash
# Check programs point to Nix store
which nvim
which tmux
which git
# All should show /nix/store/... paths

# Test programs
nvim --version
tmux -V
git --version

# Test modern CLI tools
ls   # Should use eza with icons
bat README.md   # Should show syntax highlighting
```

### 3. Configure Git (if needed)

```bash
# Edit git config
nvim ~/Documents/GitHub/dotfiles/home/programs/git.nix

# Update userName and userEmail, then rebuild
home-manager switch --flake ~/Documents/GitHub/dotfiles#chrisloidolt
```

### 4. Setup SSH Keys (Optional)

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

## Customization

### Change Installed Packages

Edit `home/packages.nix`:

```nix
home.packages = with pkgs; [
  git
  your-new-package  # Add here
];
```

Then rebuild:
```bash
home-manager switch --flake ~/Documents/GitHub/dotfiles#chrisloidolt
```

### Modify Program Configs

Program configurations are in `home/programs/`:
- `zsh.nix` - Shell configuration
- `git.nix` - Git settings
- `neovim.nix` - Editor setup
- `tmux.nix` - Terminal multiplexer
- etc.

After making changes:
```bash
home-manager switch --flake ~/Documents/GitHub/dotfiles#chrisloidolt
```

## Directory Structure

```
dotfiles/
├── flake.nix            # Main entry point
├── flake.lock           # Locked dependency versions
│
├── home/                # Home Manager configuration
│   ├── default.nix     # Main home configuration
│   ├── packages.nix    # Package list
│   └── programs/       # Program-specific configs
│       ├── zsh.nix
│       ├── starship.nix
│       ├── git.nix
│       ├── tmux.nix
│       ├── neovim.nix
│       ├── fzf.nix
│       └── direnv.nix
│
├── configs/            # Configuration files
│   ├── neovim/        # Neovim config
│   ├── opencode/      # OpenCode AI editor config
│   ├── ghostty/       # Ghostty terminal config
│   └── tmux/          # Tmux config
│
├── hosts/              # Host-specific configs
│   └── nixos-desktop/ # NixOS configuration
│
├── scripts/            # Helper scripts
│   ├── rebuild.sh     # Smart rebuild script
│   ├── update.sh      # Update flake inputs
│   └── validate-nix.sh # Validation script
│
└── docs/               # Documentation
    ├── SETUP.md        # This file
    ├── NIX_ARCHITECTURE.md
    ├── EMERGENCY_PROCEDURES.md
    ├── TROUBLESHOOTING.md
    └── QUICK_REFERENCE.md
```

## Common Operations

### Update All Packages

```bash
cd ~/Documents/GitHub/dotfiles

# Update flake.lock to latest package versions
nix flake update

# Rebuild with new packages
home-manager switch --flake .#chrisloidolt
```

### Rollback to Previous Generation

If something breaks:

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
# Search nixpkgs
nix search nixpkgs ripgrep
nix search nixpkgs nodejs

# Or use the website
# https://search.nixos.org/packages
```

## Troubleshooting

### Build Fails

```bash
# Check for syntax errors
nix flake check

# Build with full trace
nix build .#homeConfigurations.chrisloidolt.activationPackage --show-trace
```

### Terminal Doesn't Start

```bash
# Rollback to previous generation
home-manager generations
/nix/store/PREVIOUS-HASH-home-manager-generation/activate
```

### Programs Not Found

```bash
# Check if in PATH
echo $PATH | grep nix-profile

# Rebuild
home-manager switch --flake ~/Documents/GitHub/dotfiles#chrisloidolt
```

### Config Changes Not Applied

```bash
# Make sure files are tracked by git
git status

# Rebuild (use --impure if you have uncommitted changes)
home-manager switch --flake ~/Documents/GitHub/dotfiles#chrisloidolt --impure
```

See [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for more detailed troubleshooting steps.

## Keeping Dotfiles Updated

### Pull Latest Changes

```bash
cd ~/Documents/GitHub/dotfiles
git pull
```

### Rebuild After Pull

```bash
home-manager switch --flake ~/Documents/GitHub/dotfiles#chrisloidolt
```

### Backup Your Configuration

Before major changes:
```bash
cd ~/Documents/GitHub/dotfiles
git status          # Check what's changed
git add .
git commit -m "Backup before changes"
git push
```

## Security Notes

- Never commit API keys or secrets to git
- Use environment variables for sensitive data
- SSH private keys stay local (never copy between machines)
- Use password manager for sensitive credentials

## Next Steps

After setup:
1. Customize shell prompt (edit Starship config in `home/programs/starship.nix`)
2. Configure Git globally (edit `home/programs/git.nix`)
3. Explore Neovim plugins (`configs/neovim/`)
4. Set up project-specific environments with direnv

## Getting Help

- Check [README.md](../README.md) for overview
- Check [NIX_ARCHITECTURE.md](NIX_ARCHITECTURE.md) for how it works
- Check [EMERGENCY_PROCEDURES.md](EMERGENCY_PROCEDURES.md) for recovery
- Check [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for common issues
- Check [QUICK_REFERENCE.md](QUICK_REFERENCE.md) for command reference

Enjoy your new development environment! 🚀
