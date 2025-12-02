# Dotfiles

Cross-platform dotfiles managed with **Home Manager** (Nix).

## Quick Start

### macOS

```bash
# Install Nix
sh <(curl -L https://nixos.org/nix/install) --daemon

# Enable flakes
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf

# Clone and activate
git clone https://github.com/loidolt/dotfiles.git ~/Documents/GitHub/dotfiles
cd ~/Documents/GitHub/dotfiles
nix run home-manager/master -- switch --flake .#chrisloidolt

# Install fonts (one-time, via Homebrew)
brew install --cask font-fira-code-nerd-font font-jetbrains-mono-nerd-font font-meslo-lg-nerd-font
```

### Linux / WSL2

```bash
# Install Nix
sh <(curl -L https://nixos.org/nix/install) --daemon

# Enable flakes
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf

# Clone and activate
git clone https://github.com/loidolt/dotfiles.git ~/dotfiles
cd ~/dotfiles
nix run home-manager/master -- switch --flake .#chrisloidolt-linux
```

### Daily Usage

```bash
# Rebuild after changes
hm   # alias for home-manager switch

# Update packages
cd ~/Documents/GitHub/dotfiles && nix flake update && hm

# Rollback
home-manager generations
/nix/store/<hash>-home-manager-generation/activate
```

## What's Included

### Programs Configured
- **Neovim** - Modern text editor with LSP support
- **Zsh** - Shell with oh-my-zsh, autosuggestions, and syntax highlighting
- **Starship** - Modern, fast prompt with git integration
- **Git** - Version control with delta for beautiful diffs
- **Tmux** - Terminal multiplexer with truecolor support
- **FZF** - Fuzzy finder with fd integration
- **Direnv** - Per-directory environments with nix-direnv

### Modern CLI Tools
- **ripgrep** - Fast grep alternative
- **fd** - Fast find alternative
- **bat** - Cat with syntax highlighting
- **eza** - Modern ls with icons
- **zoxide** - Smart cd command
- **lazygit** - Terminal UI for git
- **btop** - System monitor

### Languages & Runtimes
- Node.js 20 (LTS)
- Bun
- TypeScript, Prettier, ESLint
- Devbox (for per-project environments)

## Repository Structure

```
dotfiles/
├── flake.nix                 # Nix flake - entry point
├── flake.lock                # Locked dependency versions
├── user.nix                  # User config (username, git)
├── home/
│   ├── default.nix           # Main home configuration
│   ├── packages.nix          # Package list
│   ├── dotfiles.nix          # Environment variables
│   └── programs/
│       ├── zsh.nix
│       ├── git.nix
│       ├── neovim.nix
│       ├── tmux.nix
│       ├── starship.nix
│       ├── fzf.nix
│       ├── direnv.nix
│       └── ssh.nix
├── configs/
│   ├── neovim/               # Neovim config
│   ├── opencode/             # OpenCode AI editor config
│   └── ghostty/              # Ghostty terminal config
├── project-templates/        # Devbox templates
│   ├── python/
│   ├── nodejs/
│   ├── golang/
│   ├── infrastructure/
│   └── kubernetes/
├── scripts/
│   └── rebuild.sh            # Rebuild helper
└── docs/
    └── SETUP.md              # Detailed setup guide
```

## Per-Project Environments

Use Devbox for project-specific tooling:

```bash
cd my-project
devbox init
devbox add python@3.12 poetry
devbox shell
```

See `project-templates/` for pre-configured environments.

## Customization

### Adding Packages

Edit `home/packages.nix`:

```nix
home.packages = with pkgs; [
  # Add your packages here
  your-new-package
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
nix build .#homeConfigurations.chrisloidolt.activationPackage --show-trace
```

### Rollback

```bash
# List previous generations
home-manager generations

# Activate a previous generation
/nix/store/HASH-home-manager-generation/activate
```

### Programs Not Found

```bash
# Check if in PATH
echo $PATH | grep nix-profile

# Rebuild
hm
```

## Philosophy

This dotfiles system follows these principles:

1. **Declarative** - Describe what you want, not how to get it
2. **Reproducible** - Same inputs = same outputs, always
3. **Atomic** - Changes are all-or-nothing, no partial states
4. **Rollback** - Can revert to any previous generation
5. **Simple** - Home Manager only, no system-level complexity

## License

See the LICENSE file for details.
