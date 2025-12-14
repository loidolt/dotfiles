# Dotfiles

Cross-platform dotfiles managed with **Home Manager** (Nix).

## Quick Start

### Automated Setup (Recommended)

The easiest way to get started is using our two-step automated setup process:

#### Step 1: Initial System Setup

This installs only the bare minimum (git, curl, Nix) required to bootstrap the system.

**macOS / Linux:**

```bash
# Clone the repository first
git clone https://github.com/YOUR_USERNAME/dotfiles.git ~/dotfiles
cd ~/dotfiles

# Run initial setup (installs Nix and dependencies)
bash scripts/initial-setup.sh

# Close terminal and open a new one (IMPORTANT!)
```

**Supported Linux Distributions:**
- **Debian-based**: Debian, Ubuntu, Kali, Linux Mint, Pop!_OS, Elementary, etc.
- **Fedora-based**: Fedora, RHEL, CentOS, Rocky, AlmaLinux, etc.
- **Arch-based**: Arch, Manjaro, EndeavourOS, Garuda, etc.

**Windows (WSL2):**

Run in PowerShell as Administrator:

```powershell
# Download and run the Windows setup
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/YOUR_USERNAME/dotfiles/main/scripts/setup-windows-initial.ps1" -OutFile "$env:TEMP\setup-windows-initial.ps1"
& "$env:TEMP\setup-windows-initial.ps1"
```

#### Step 2: Install Dotfiles

After restarting your terminal, install the actual dotfiles configuration:

```bash
cd ~/dotfiles
bash scripts/install-dotfiles.sh
```

This script will:
- Auto-detect your platform (macOS/Linux, x86/ARM)
- Verify your user configuration
- Install Home Manager with all tools and configurations
- Set up ZSH as your default shell (optional)
- Verify the installation

**That's it!** Your development environment is now fully configured.

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

### What Gets Installed

**Step 1 (`initial-setup.sh`)** installs these essential components:
- **macOS**: Xcode Command Line Tools (git), curl, Nix
- **Debian-based**: git, curl, xz-utils, ca-certificates, Nix
- **Fedora-based**: git, curl, xz, ca-certificates, Nix  
- **Arch-based**: git, curl, xz, ca-certificates-utils, Nix
- **Windows**: WSL2 + Ubuntu (then follow Linux steps inside WSL)

**Step 2 (`install-dotfiles.sh`)** installs everything else via Nix and Home Manager:
- All CLI tools and programs listed below
- ZSH with custom configuration
- Neovim, Tmux, Git, and other development tools
- Your personalized environment

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
│   ├── initial-setup.sh      # Bootstrap Nix installation
│   ├── install-dotfiles.sh   # Install dotfiles with Home Manager
│   ├── update.sh             # Update flake inputs
│   ├── health-check.sh       # Verify installation
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
