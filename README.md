# Dotfiles

> **⚠️ Currently migrating from Ansible to Nix!** See [MIGRATION_README.md](MIGRATION_README.md) for details.

Declarative, reproducible development environment managed with **Nix** and **Home Manager**.

## Overview

This repository provides a **declarative development environment** that includes:

### Managed with Nix + Home Manager ✨
- **Declarative configuration** - One source of truth for all settings
- **Reproducible** - Same config works on macOS, NixOS, and WSL2
- **Atomic updates** - All-or-nothing changes
- **Rollback support** - Return to any previous state
- **Cross-platform** - Same dotfiles on all systems

### Programs Configured
- **Neovim** (v0.11.5) - Modern text editor with LSP support
- **Zsh** - Shell with oh-my-zsh, autosuggestions, and syntax highlighting
- **Starship** - Modern, fast prompt with git integration
- **Git** - Version control with delta for beautiful diffs
- **Tmux** - Terminal multiplexer with truecolor support
- **Modern CLI tools** - eza, bat, ripgrep, fd, fzf, zoxide, and more
- **OpenCode** - AI-powered code editor CLI
- **Ghostty** - GPU-accelerated terminal emulator

### Legacy System (Being Phased Out)
- **Ansible automation** - In `legacy/` directory (archived)
- Use Nix instead for new installations

## Repository Structure

```
dotfiles/
├── flake.nix            # 🎯 Nix flake - main entry point
├── flake.lock           # Locked dependency versions
│
├── home/                # 🏠 Home Manager configuration
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
├── configs/            # 📝 Configuration files
│   ├── neovim/        # Neovim config (synced from separate repo)
│   ├── opencode/      # OpenCode AI editor config
│   ├── ghostty/       # Ghostty terminal config
│   └── tmux/          # Tmux config
│
├── hosts/              # 💻 Host-specific configs (future use)
│   ├── darwin/        # macOS configurations
│   ├── nixos-desktop/ # NixOS desktop
│   └── wsl/           # WSL2 configuration
│
├── scripts/            # 🔧 Helper scripts
│   └── validate-nix.sh # Validation script
│
├── docs/               # 📚 Documentation
│   ├── NIX_MIGRATION_GUIDE.md
│   ├── EMERGENCY_PROCEDURES.md
│   └── QUICK_REFERENCE.md
│
├── ansible/            # 🗄️ Legacy - being phased out
└── MIGRATION_README.md # Migration guide
```

## Quick Start

### 🚀 macOS Setup (Home Manager)

**Current Status:** ✅ Home Manager is working on macOS!

```bash
# Clone the repo
git clone https://github.com/loidolt/dotfiles.git ~/Documents/GitHub/dotfiles
cd ~/Documents/GitHub/dotfiles

# Install Nix (if not already installed)
sh <(curl -L https://nixos.org/nix/install) --daemon

# Enable flakes
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf

# Activate Home Manager
nix run home-manager/master -- switch --flake .#chrisloidolt -b backup

# Close and reopen your terminal
```

This will install and configure:
- ✅ All packages (git, curl, neovim, tmux, etc.)
- ✅ Zsh with oh-my-zsh and plugins
- ✅ Starship prompt
- ✅ Modern CLI tools (eza, bat, ripgrep, fd, fzf, zoxide)
- ✅ Neovim with LSP servers
- ✅ Git with delta
- ✅ Tmux with truecolor
- ✅ All program configurations

### 🔄 Making Changes

After editing configuration files:

```bash
# Rebuild and activate
home-manager switch --flake .#chrisloidolt

# Or with uncommitted changes
home-manager switch --flake .#chrisloidolt --impure
```

### 📦 Adding Packages

Edit `home/packages.nix` and add your package:

```nix
home.packages = with pkgs; [
  # ... existing packages ...
  your-new-package
];
```

Then rebuild:
```bash
home-manager switch --flake .#chrisloidolt
```

### ↩️ Rollback

If something breaks, you can rollback:

```bash
# List previous generations
home-manager generations

# Activate a previous generation
/nix/store/HASH-home-manager-generation/activate
```

## What's Installed

### Core Packages
- git, curl, wget, vim, tmux, htop, tree, jq, unzip

### Modern CLI Tools
- **ripgrep** - Fast grep alternative
- **fd** - Fast find alternative
- **bat** - Cat with syntax highlighting
- **fzf** - Fuzzy finder
- **eza** - Modern ls with icons
- **zoxide** - Smart cd command
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

See [`home/packages.nix`](home/packages.nix) for the complete list.

## Customization

### Adding Packages

Edit `home/packages.nix`:

```nix
home.packages = with pkgs; [
  # Add your packages here
  ripgrep
  fd
  your-new-package
];
```

### Modifying Program Configs

Program configurations are in `home/programs/`:
- `zsh.nix` - Shell configuration
- `git.nix` - Git settings
- `neovim.nix` - Editor setup
- `tmux.nix` - Terminal multiplexer
- etc.

After making changes, rebuild:
```bash
home-manager switch --flake .#chrisloidolt
```

## Migration Status

- ✅ **Phase 0**: Nix installation complete
- ✅ **Phase 1**: Flake structure created
- ✅ **Phase 2**: Home Manager active on macOS
- ✅ **Phase 3**: NixOS VM testing complete
- ⏭️ **Phase 4**: NixOS production (skipped)
- ⏭️ **Phase 5**: WSL2 configuration (skipped)
- 🔄 **Phase 6**: Validation & cleanup (in progress)
- ⬜ **Phase 7**: Documentation & polish

See [MIGRATION_README.md](MIGRATION_README.md) for full details.

## Advanced Usage

### Update All Packages

```bash
cd ~/Documents/GitHub/dotfiles

# Update flake.lock to latest package versions
nix flake update

# Rebuild with new packages
home-manager switch --flake .#chrisloidolt
```

### Clean Old Generations

```bash
# List all generations
home-manager generations

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

## Configuration Details

### Programs
- **Neovim** - Based on LazyVim, LSP servers managed by Nix
- **OpenCode** - AI editor with MCP servers (context7, sequentialthinking, etc.)
- **Git** - Delta integration for beautiful diffs
- **Tmux** - Truecolor support, vi-mode, custom keybindings
- **Zsh** - oh-my-zsh with autosuggestions and syntax highlighting
- **Starship** - Fast, customizable prompt

### Documentation

- **[MIGRATION_README.md](MIGRATION_README.md)** - Migration guide and overview
- **[docs/NIX_MIGRATION_GUIDE.md](docs/NIX_MIGRATION_GUIDE.md)** - Detailed Nix setup
- **[docs/EMERGENCY_PROCEDURES.md](docs/EMERGENCY_PROCEDURES.md)** - Troubleshooting
- **[docs/QUICK_REFERENCE.md](docs/QUICK_REFERENCE.md)** - Command reference
- **Config READMEs:**
  - [configs/opencode/README.md](configs/opencode/README.md)
  - [configs/neovim/README.md](configs/neovim/README.md)
  - [configs/tmux/README.md](configs/tmux/README.md)

## How It Works

### Declarative Configuration

Everything is defined in `.nix` files:
- `flake.nix` - Entry point, defines inputs and outputs
- `home/default.nix` - Main home configuration
- `home/packages.nix` - Package list
- `home/programs/*.nix` - Individual program configs

### Home Manager

Home Manager creates symlinks from the Nix store to your home directory:
- Configs in `configs/` → Nix store → `~/.config/`
- Programs installed to `/nix/store/` → Available in `~/.nix-profile/bin/`

**Benefits:**
- ✅ Declarative - describe what you want, not how to get it
- ✅ Reproducible - same config = same result
- ✅ Atomic - all-or-nothing updates
- ✅ Rollback - return to any previous generation

### Architecture

```
flake.nix
    ↓
home-manager (reads home/default.nix)
    ↓
Imports: packages.nix, programs/*.nix
    ↓
Builds derivations in /nix/store
    ↓
Creates symlinks: ~/.config, ~/.nix-profile, etc.
    ↓
Activation: sets up shell, PATH, environment
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
home-manager switch --flake .#chrisloidolt
```

### Config Changes Not Applied

```bash
# Make sure files are tracked by git
git status

# Rebuild
home-manager switch --flake .#chrisloidolt
```

See [docs/EMERGENCY_PROCEDURES.md](docs/EMERGENCY_PROCEDURES.md) for detailed troubleshooting.

## Features

✨ **Declarative** - One source of truth for all configuration  
🔄 **Reproducible** - Same config works everywhere  
⚛️ **Atomic** - All-or-nothing updates  
↩️ **Rollback** - Return to any previous state  
🌍 **Cross-platform** - macOS, NixOS, WSL2  
📦 **Modern tools** - Latest packages from nixpkgs  
🔒 **Immutable** - Packages can't be accidentally broken  
📝 **Well-documented** - Comprehensive migration guides  

## Philosophy

This dotfiles system follows these principles:

1. **Declarative** - Describe what you want, not how to get it
2. **Reproducible** - Same inputs = same outputs, always
3. **Atomic** - Changes are all-or-nothing, no partial states
4. **Rollback** - Can revert to any previous generation
5. **Transparent** - All configs in version control
6. **Safe** - Test changes before applying

## Contributing

This is a personal dotfiles repository, but feel free to:
- **Fork it** and customize for your needs
- **Star it** if you find it useful
- **Share it** with others learning dotfiles management

## License

See the LICENSE file for details.

---

**Happy coding!** 🚀

For detailed setup instructions, see [docs/SETUP.md](docs/SETUP.md)