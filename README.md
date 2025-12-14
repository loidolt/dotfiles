# Dotfiles

Cross-platform dotfiles managed with **Home Manager** (Nix).

## Quick Start

### Automated Setup (Recommended)

The easiest way to get started is using the automated initial setup scripts. These install only the bare minimum required for Nix to work.

#### macOS / Linux

```bash
# Download and run the initial setup
curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/dotfiles/main/scripts/initial-setup.sh | bash
```

Or if you've already cloned the repository:

```bash
cd ~/dotfiles
bash scripts/initial-setup.sh
```

#### Windows (WSL2)

Run in PowerShell as Administrator:

```powershell
# Download and run the Windows setup
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/YOUR_USERNAME/dotfiles/main/scripts/setup-windows-initial.ps1" -OutFile "$env:TEMP\setup-windows-initial.ps1"
& "$env:TEMP\setup-windows-initial.ps1"
```

Or if you've already cloned the repository:

```powershell
cd ~/dotfiles/scripts
.\setup-windows-initial.ps1
```

### Manual Setup

If you prefer to install manually:

#### macOS

```bash
# Install Nix (with flakes support)
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install

# Clone and activate
git clone https://github.com/loidolt/dotfiles.git ~/Documents/GitHub/dotfiles
cd ~/Documents/GitHub/dotfiles
nix run home-manager/master -- switch --flake .#chrisloidolt --impure

# Install fonts (one-time, via Homebrew)
brew install --cask font-fira-code-nerd-font font-jetbrains-mono-nerd-font font-meslo-lg-nerd-font
```

#### Linux / WSL2

```bash
# Install Nix (with flakes support)
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install

# Clone and activate
git clone https://github.com/loidolt/dotfiles.git ~/dotfiles
cd ~/dotfiles
nix run home-manager/master -- switch --flake .#chrisloidolt-linux --impure
```

### What Gets Installed Initially

The initial setup scripts install **only** these essential components:

- **macOS**: Xcode Command Line Tools (git), curl, Nix
- **Debian/Ubuntu**: git, curl, xz-utils, ca-certificates, Nix
- **Fedora/RHEL**: git, curl, xz, ca-certificates, Nix  
- **Arch Linux**: git, curl, xz, ca-certificates-utils, Nix
- **Windows**: WSL2 + Ubuntu (then follow Linux steps inside WSL)

Everything else (shell, editor, CLI tools, etc.) is managed by Nix and Home Manager.

### Daily Usage

```bash
# Rebuild after changes
hm              # alias for home-manager switch

# Update flake inputs and rebuild
hm-update       # runs update.sh with interactive prompts

# Validate your setup
hm-validate     # comprehensive system validation
dotfiles-check  # quick flake check

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
- **lazydocker** - Terminal UI for docker
- **lazysql** - Terminal UI for databases
- **btop** - System monitor
- **glow** - Markdown renderer
- **yq** - YAML/TOML processor
- **tldr** - Simplified man pages
- **dust** - Disk usage visualization
- **hyperfine** - Command benchmarking
- **jless** - Interactive JSON viewer
- **procs** - Better process viewer
- **xh** - HTTP client with better UX

### Languages & Runtimes
- Node.js 20 (LTS)
- Bun
- TypeScript, Prettier, ESLint
- Devbox (for per-project environments)

### Cloud & Infrastructure Tools
- **google-cloud-sdk** - Google Cloud Platform tools

**Note:** Wrangler (Cloudflare Workers CLI) is available in the `project-templates/cloudflare/` devbox template to avoid package conflicts with global Node.js tooling.

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
│   ├── cloudflare/           # Cloudflare Workers
│   ├── infrastructure/
│   └── kubernetes/
├── scripts/
│   ├── update.sh             # Update flake inputs
│   └── validate-nix.sh       # Validate Nix setup
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
nix build .#homeConfigurations.chrisloidolt.activationPackage --show-trace --impure
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
