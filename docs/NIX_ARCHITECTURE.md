# Nix Configuration Architecture

This document explains how this Nix-based dotfiles repository is structured and how the different components work together.

## Overview

This repository uses **Nix Flakes** and **Home Manager** to provide a declarative, reproducible development environment across multiple platforms (macOS, NixOS, WSL2).

## Directory Structure

```
dotfiles/
├── flake.nix                    # Entry point - defines all inputs and outputs
├── flake.lock                   # Locked versions of all dependencies
├── user.nix                     # User-specific values (username, git, timezone)
│
├── home/                        # Home Manager user environment
│   ├── default.nix             # Main home configuration
│   ├── dotfiles.nix            # DOTFILES path configuration
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
├── hosts/                       # Host-specific configurations
│   ├── darwin/                 # macOS (nix-darwin)
│   │   └── default.nix
│   ├── nixos-desktop/          # NixOS ARM64 (Parallels, etc.)
│   │   ├── default.nix
│   │   ├── host.nix            # Host-specific customizations
│   │   └── hardware-configuration.nix
│   ├── lra-chrislw/            # NixOS x86_64 on Proxmox VM
│   │   ├── default.nix
│   │   ├── host.nix            # Host-specific customizations
│   │   └── hardware-configuration.nix
│   ├── epa-cloidoltlw/         # NixOS x86_64 on bare metal
│   │   ├── default.nix
│   │   ├── host.nix            # Host-specific customizations
│   │   └── hardware-configuration.nix
│   ├── nixos-headless/         # NixOS headless server
│   │   ├── default.nix
│   │   ├── host.nix            # Host-specific customizations
│   │   └── hardware-configuration.nix
│   └── wsl/                    # WSL2 configuration
│       └── default.nix
│
├── modules/                     # Shared configuration modules
│   ├── shared/                 # Cross-platform modules
│   │   ├── nix-settings.nix   # Nix daemon configuration
│   │   └── fonts.nix          # Font packages
│   └── nixos/                  # NixOS-specific modules
│       ├── base.nix           # Common NixOS settings
│       ├── graphical.nix      # Desktop environment
│       └── headless.nix       # Server profile
│
├── configs/                     # Raw configuration files
│   ├── neovim/                 # Neovim config (Lua)
│   ├── opencode/               # OpenCode AI editor config
│   └── ghostty/                # Ghostty terminal config
│
├── scripts/                     # Helper scripts
│   ├── rebuild.sh              # Smart rebuild (auto-detects platform)
│   ├── update.sh               # Update flake inputs
│   └── validate-nix.sh         # Validate setup
│
└── docs/                        # Documentation
    ├── SETUP.md                # Setup guide
    ├── NIX_ARCHITECTURE.md     # This file
    ├── EMERGENCY_PROCEDURES.md # Troubleshooting
    ├── TROUBLESHOOTING.md      # Common issues
    ├── PACKAGE_MANAGEMENT_GUIDE.md
    └── QUICK_REFERENCE.md      # Quick command reference
```

## How It Works

### 1. Flake Entry Point (`flake.nix`)

The `flake.nix` file is the entry point for the entire configuration. It:

- **Defines inputs**: External dependencies (nixpkgs, home-manager, nix-darwin, nixos-wsl)
- **Defines outputs**: Configurations for different platforms
- **Provides helper functions**: `mkNixosHost`, `mkDarwinHost`, `mkHomeConfig` to reduce boilerplate
- **Imports user config**: From `user.nix` for personalization

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nixos-wsl.url = "github:nix-community/NixOS-WSL";
  };
  
  outputs = { ... }: {
    # Helper functions reduce boilerplate
    darwinConfigurations.darwin-arm64 = mkDarwinHost { ... };
    nixosConfigurations.nixos-desktop = mkNixosHost { ... };
    homeConfigurations.chrisloidolt = mkHomeConfig { ... };
  };
}
```

### 2. User Configuration (`user.nix`)

Centralized user-specific values that can be easily customized:

```nix
{
  username = "chrisloidolt";
  vmUsername = "loidolt";
  git = {
    name = "Chris Loidolt";
    email = "477898+loidolt@users.noreply.github.com";
  };
  timezone = "America/Denver";
  locale = "en_US.UTF-8";
}
```

### 3. Shared Modules (`modules/shared/`)

Cross-platform modules eliminate duplication:

- **`nix-settings.nix`**: Flakes, caches, garbage collection (works on Darwin, NixOS, and Home Manager)
- **`fonts.nix`**: Nerd Fonts configuration

### 4. Home Manager (User Environment)

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

### 5. NixOS Configurations

NixOS hosts import hardware config from `/etc/nixos/` (not tracked in git):

```nix
# hosts/nixos-desktop/default.nix
{
  imports = [
    ./hardware-configuration.nix  # Machine-specific (committed to repo)
    ../../modules/shared/nix-settings.nix
    ../../modules/nixos/base.nix
    ../../modules/nixos/graphical.nix
  ];
}
```

**Note:** Each NixOS host has a `hardware-configuration.nix` that must be generated on the target machine and committed to the repo for reproducibility.

### 6. Platform Support

| Platform | Configuration | Command |
|----------|--------------|---------|
| macOS (Darwin) | `darwinConfigurations.darwin-arm64` | `darwin-rebuild switch --flake .#darwin-arm64` |
| macOS (Home Manager only) | `homeConfigurations.chrisloidolt` | `home-manager switch --flake .#chrisloidolt` |
| NixOS ARM64 | `nixosConfigurations.nixos-desktop` | `sudo nixos-rebuild switch --flake .#nixos-desktop` |
| NixOS Proxmox VM | `nixosConfigurations.lra-chrislw` | `sudo nixos-rebuild switch --flake .#lra-chrislw` |
| NixOS Bare Metal | `nixosConfigurations.epa-cloidoltlw` | `sudo nixos-rebuild switch --flake .#epa-cloidoltlw` |
| NixOS Headless | `nixosConfigurations.nixos-headless` | `sudo nixos-rebuild switch --flake .#nixos-headless` |
| WSL2 | `nixosConfigurations.wsl` | `sudo nixos-rebuild switch --flake .#wsl` |

## Key Concepts

### Declarative Configuration

Everything is declared in `.nix` files. You describe **what** you want, not **how** to get it.

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
sudo nixos-rebuild switch --rollback
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

### Customizing for Your Setup

1. Edit `user.nix` with your username, git config, timezone
2. Rebuild

### Adding a New NixOS Host

```nix
# In flake.nix, add to nixosConfigurations:
my-new-host = mkNixosHost {
  system = "x86_64-linux";
  hostPath = ./hosts/my-new-host;
  hostUsername = vmUsername;
};
```

Then create the host directory with:
- `default.nix` - Main config importing modules
- `host.nix` - Host-specific customizations
- `hardware-configuration.nix` - Generated hardware config

### Host-Specific Customizations

Each NixOS host has a `host.nix` file for machine-specific settings:

```nix
# hosts/my-host/host.nix
{ config, pkgs, lib, ... }:

{
  # Add host-specific packages
  environment.systemPackages = with pkgs; [
    some-special-tool
  ];

  # Override shared module defaults
  services.printing.enable = false;

  # Hardware-specific settings
  hardware.nvidia.enable = true;
}
```

Common customizations:
- **VM hosts**: Guest tools, spice agent, disable firmware updates
- **Bare metal**: GPU drivers, CPU microcode, sensors, power management
- **Servers**: Security hardening, specific services, firewall rules

The `host.nix` is imported before shared modules, so you can use `lib.mkForce` to override defaults set with `lib.mkDefault`.

## File Paths

### Important Nix Paths

- `/nix/store/` - All packages and configurations
- `~/.nix-profile/` - Current user environment
- `/run/current-system/` - Current NixOS system (NixOS only)
- `/etc/nixos/hardware-configuration.nix` - Machine-specific hardware config (NixOS)

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

### NixOS Hardware Config Issues

```bash
# Regenerate hardware config on the target machine
sudo nixos-generate-config --show-hardware-config > hardware-configuration.nix

# Copy to the appropriate host directory and commit
cp hardware-configuration.nix ~/dotfiles/hosts/lra-chrislw/

# Then rebuild
sudo nixos-rebuild switch --flake .#lra-chrislw
```

## Best Practices

1. **Commit before major changes** - Easy to revert via git
2. **Test in VM first** - For NixOS system changes
3. **Edit `user.nix` for personalization** - Don't hardcode values
4. **Use shared modules** - Avoid duplication
5. **Commit hardware configs** - In host directories for reproducibility
6. **Pin versions** - Use flake.lock for reproducibility

## References

- [Nix Manual](https://nixos.org/manual/nix/stable/)
- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [Nix Package Search](https://search.nixos.org/)
- [NixOS Wiki](https://nixos.wiki/)
