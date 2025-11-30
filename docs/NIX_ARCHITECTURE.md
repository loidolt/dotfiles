# Nix Configuration Architecture

This document explains how this Nix-based dotfiles repository is structured and how the different components work together.

## Overview

This repository uses **Nix Flakes** and **Home Manager** to provide a declarative, reproducible development environment across multiple platforms (macOS, NixOS, WSL2).

## Directory Structure

```
dotfiles/
├── flake.nix                    # Entry point - defines all inputs and outputs
├── flake.lock                   # Locked versions of all dependencies
│
├── home/                        # Home Manager user environment
│   ├── default.nix             # Main home configuration
│   ├── packages.nix            # Package declarations
│   └── programs/               # Program-specific configurations
│       ├── zsh.nix
│       ├── starship.nix
│       ├── git.nix
│       ├── tmux.nix
│       ├── neovim.nix
│       ├── fzf.nix
│       └── direnv.nix
│
├── hosts/                       # System-level configurations
│   ├── nixos-desktop/          # NixOS configuration
│   │   ├── default.nix
│   │   └── hardware-configuration.nix
│   ├── darwin/                 # macOS (nix-darwin) - future
│   └── wsl/                    # WSL2 configuration - future
│
├── configs/                     # Raw configuration files
│   ├── neovim/                 # Neovim config (LazyVim)
│   ├── opencode/               # OpenCode AI editor config
│   ├── ghostty/                # Ghostty terminal config
│   └── tmux/                   # Tmux config
│
├── scripts/                     # Helper scripts
│   ├── rebuild.sh              # Smart rebuild (auto-detects platform)
│   ├── update.sh               # Update flake inputs
│   └── validate-nix.sh         # Validate setup
│
└── docs/                        # Documentation
    ├── NIX_ARCHITECTURE.md     # This file
    ├── NIX_MIGRATION_GUIDE.md  # Migration guide
    ├── EMERGENCY_PROCEDURES.md # Troubleshooting
    └── QUICK_REFERENCE.md      # Quick command reference
```

## How It Works

### 1. Flake Entry Point (`flake.nix`)

The `flake.nix` file is the entry point for the entire configuration. It:

- **Defines inputs**: External dependencies (nixpkgs, home-manager, etc.)
- **Defines outputs**: What this flake provides (configurations for different platforms)
- **Manages versions**: Via `flake.lock` for reproducibility

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  
  outputs = { nixpkgs, home-manager, ... }: {
    # Home Manager for macOS
    homeConfigurations.chrisloidolt = ...;
    
    # NixOS system configuration
    nixosConfigurations.nixos-desktop = ...;
  };
}
```

### 2. Home Manager (User Environment)

Home Manager manages your user-level environment:

**Configuration Flow:**
```
flake.nix
    ↓
home/default.nix (main config)
    ↓
├── packages.nix (list of packages to install)
├── programs/zsh.nix (shell configuration)
├── programs/git.nix (git configuration)
└── programs/*.nix (other programs)
    ↓
Nix builds all configurations
    ↓
Creates symlinks in ~/.config/, ~/.nix-profile/, etc.
```

**What Home Manager Does:**
- Installs packages to `/nix/store/`
- Creates symlinks from Nix store to your home directory
- Manages program configurations
- Handles environment variables and shell setup
- Can be rolled back to previous generations

### 3. NixOS (System Configuration)

For NixOS systems, the system-level configuration is in `hosts/nixos-desktop/`:

```nix
hosts/nixos-desktop/
├── default.nix                 # System configuration
└── hardware-configuration.nix  # Hardware-specific settings
```

**NixOS Configuration Flow:**
```
flake.nix
    ↓
hosts/nixos-desktop/default.nix
    ├── System packages
    ├── Services (Docker, SSH, etc.)
    ├── Desktop environment (KDE Plasma)
    └── Home Manager integration
        ↓
    home/default.nix (user config)
```

### 4. Platform Detection

The repository supports multiple platforms:

- **macOS**: Home Manager standalone
- **NixOS**: NixOS system + Home Manager
- **WSL2**: NixOS-WSL + Home Manager (future)

The `scripts/rebuild.sh` script automatically detects your platform and runs the appropriate rebuild command.

## Key Concepts

### Declarative Configuration

Everything is declared in `.nix` files. You describe **what** you want, not **how** to get it.

**Example:** Instead of:
```bash
brew install neovim
brew install tmux
# ... manual configuration ...
```

You write:
```nix
home.packages = [ pkgs.neovim pkgs.tmux ];
programs.neovim.enable = true;
```

### Reproducibility

The same configuration files produce the same result every time:

- `flake.lock` pins exact versions of all dependencies
- Nix builds in isolated environments
- No hidden dependencies or system state

### Atomicity

Changes are all-or-nothing:

- If a build fails, nothing changes
- If a build succeeds, everything activates together
- No partial updates or broken states

### Rollback

Every change creates a new "generation":

```bash
# List all generations
home-manager generations        # macOS
nixos-rebuild list-generations  # NixOS

# Rollback to previous generation
/nix/store/HASH-home-manager-generation/activate
sudo nixos-rebuild switch --rollback
```

## Configuration Layers

### Layer 1: Packages (`home/packages.nix`)

Basic package installation:

```nix
home.packages = with pkgs; [
  git
  neovim
  tmux
  # ...
];
```

### Layer 2: Program Configuration (`home/programs/`)

Program-specific settings using Home Manager modules:

```nix
programs.git = {
  enable = true;
  userName = "Your Name";
  userEmail = "you@example.com";
  # ...
};
```

### Layer 3: Raw Config Files (`configs/`)

For programs not fully supported by Home Manager:

```nix
xdg.configFile."nvim" = {
  source = ../configs/neovim;
  recursive = true;
};
```

### Layer 4: System Configuration (`hosts/`)

NixOS-only system-level settings:

```nix
services.docker.enable = true;
services.openssh.enable = true;
# ...
```

## Build Process

### macOS (Home Manager)

```bash
# User runs:
home-manager switch --flake .#chrisloidolt

# What happens:
1. Nix evaluates flake.nix
2. Reads home/default.nix and all imports
3. Builds derivations in /nix/store/
4. Creates generation number N
5. Creates symlinks:
   ~/.config/ → /nix/store/.../config/
   ~/.nix-profile/ → /nix/store/.../profile/
6. Runs activation scripts
7. Updates shell environment
```

### NixOS

```bash
# User runs:
sudo nixos-rebuild switch --flake .#nixos-desktop

# What happens:
1. Nix evaluates flake.nix
2. Reads hosts/nixos-desktop/default.nix
3. Integrates Home Manager configuration
4. Builds system closure
5. Creates generation number N
6. Switches system to new generation
7. Activates services, updates boot loader
```

## Common Operations

### Adding a Package

1. Edit `home/packages.nix`
2. Add package to the list
3. Run `scripts/rebuild.sh`

### Updating Packages

```bash
# Update all inputs and rebuild
scripts/update.sh

# Update specific input only
scripts/update.sh --input nixpkgs
```

### Rolling Back

```bash
# macOS
home-manager generations
/nix/store/PREVIOUS-HASH/activate

# NixOS
sudo nixos-rebuild switch --rollback
```

### Garbage Collection

```bash
# Delete old generations
nix-collect-garbage --delete-older-than 30d

# Optimize store (deduplicate)
nix-store --optimise
```

## File Paths

### Important Nix Paths

- `/nix/store/` - All packages and configurations
- `~/.nix-profile/` - Current user environment
- `/run/current-system/` - Current NixOS system (NixOS only)

### User Configuration Paths

- `~/.config/` - Application configurations (symlinked from Nix store)
- `~/.local/state/nix/profiles/` - Home Manager profiles
- `~/.nix-defexpr/` - Nix expressions

## Troubleshooting

### Build Fails

```bash
# Check for syntax errors
nix flake check

# Build with detailed trace
nix build .#homeConfigurations.chrisloidolt.activationPackage --show-trace
```

### Changes Not Applied

```bash
# Make sure files are tracked by git
git status

# Rebuild
scripts/rebuild.sh
```

### Rollback After Breaking Change

```bash
# macOS
home-manager generations
# Copy the previous generation path
/nix/store/HASH-home-manager-generation/activate

# NixOS
sudo nixos-rebuild switch --rollback
```

## Best Practices

1. **Commit before major changes** - Easy to revert via git
2. **Test in VM first** - For NixOS system changes
3. **Use `--impure` sparingly** - Breaks reproducibility
4. **Pin versions** - Use flake.lock for reproducibility
5. **Document changes** - Good commit messages
6. **Keep it modular** - Separate concerns into different files

## References

- [Nix Manual](https://nixos.org/manual/nix/stable/)
- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [Nix Package Search](https://search.nixos.org/)
- [NixOS Wiki](https://nixos.wiki/)

## Migration Notes

This repository was migrated from Ansible. See:
- `MIGRATION_README.md` - Migration overview
- `MIGRATION_LOG.md` - Detailed migration progress
- `legacy/` - Old Ansible configuration (archived)
