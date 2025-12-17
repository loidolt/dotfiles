# Dotfiles

> Cross-platform dotfiles using GNU Stow

**Quick Navigation:** [Quick Start](#quick-start) | [Daily Usage](#daily-usage) | [What's Included](#whats-included) | [Troubleshooting](#troubleshooting)

## Features

- 🔗 Simple symlink-based configuration management
- 📦 100+ modern CLI tools
- 🚀 Fast, lightweight setup (no Nix required)
- 💻 Works on macOS and Linux
- 🎯 Project-specific environments with Devbox
- 🛠️ Easy to customize and maintain

---

## Quick Start

### Prerequisites

- macOS or Linux
- 10-15 minutes for installation
- Internet connection

### Installation

**One-command install:**

```bash
git clone https://github.com/loidolt/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

The script will:
1. Install Homebrew (macOS) or system packages (Linux)
2. Install GNU Stow
3. Symlink all configurations to your home directory
4. Install essential packages

**That's it!** Restart your shell: `exec zsh`

---

## Daily Usage

### Managing Dotfiles

```bash
# Install/update all configs
cd ~/dotfiles
./stow-all.sh

# Install specific package
cd ~/dotfiles/stow
stow nvim     # Install neovim config
stow zsh      # Install zsh config

# Remove specific package
stow -D nvim  # Unlink neovim config

# Reinstall (useful after updates)
stow -R nvim

# Run health check
./scripts/health-check.sh

# Update packages
./scripts/update.sh
```

### Essential Commands

**Git workflows:**
```bash
gs          # git status
gc          # git commit
gp          # git push
lazygit     # Interactive Git TUI
```

**File navigation:**
```bash
ll          # List files with icons (eza)
la          # List all files including hidden
z project   # Jump to directory (zoxide smart cd)
fzf         # Fuzzy find files
```

**Modern CLI tools:**
```bash
cat file.json    # Syntax-highlighted viewer (bat)
http api.com     # HTTP requests (xh)
jless data.json  # Interactive JSON viewer
glow README.md   # Render markdown
```

See [docs/QUICK_REFERENCE.md](docs/QUICK_REFERENCE.md) for complete cheatsheet.

---

## What's Included

### Core Programs

- **Neovim** - Modern text editor with LSP support
- **Zsh** - Shell with oh-my-zsh, autosuggestions, syntax highlighting
- **Starship** - Fast prompt with git integration
- **Tmux** - Terminal multiplexer with truecolor support
- **Git** - Version control with delta for beautiful diffs

### Modern CLI Tools

**File Management:**
- `eza` - Better ls with icons and git integration
- `fd` - Fast find alternative
- `ripgrep` - Fast grep alternative  
- `bat` - Cat with syntax highlighting
- `zoxide` - Smart cd command that learns your habits

**Development:**
- `lazygit`, `lazydocker`, `lazysql` - Interactive TUIs
- `fzf` - Fuzzy finder for files, commands, history
- `direnv` - Per-directory environment variables

**Documentation & Data:**
- `glow` - Markdown renderer for the terminal
- `jless` - Interactive JSON viewer
- `yq` - YAML/TOML processor (like jq for YAML)
- `tldr` - Simplified man pages with examples

**System Utilities:**
- `btop` - Beautiful system monitor
- `dust` - Disk usage visualization
- `procs` - Better process viewer
- `hyperfine` - Command benchmarking tool

**AI Coding Tools:**
- `opencode` - AI coding agent for the terminal
- `claude-code` - Claude Code CLI

**Languages & Runtimes:**
- Node.js 20 (LTS)
- Bun
- Python 3 with development tools
- TypeScript, Prettier, ESLint

**Cloud & Infrastructure:**
- Google Cloud SDK
- Devbox (for per-project environments)

See package lists in:
- [packages/common.txt](packages/common.txt) - Cross-platform tools
- [packages/macos.txt](packages/macos.txt) - macOS-specific tools  
- [packages/linux.txt](packages/linux.txt) - Linux-specific tools

---

## Customization

### Modifying Configurations

All configurations are in the `stow/` directory:

- `stow/nvim/` - Neovim configuration
- `stow/zsh/` - Zsh shell, aliases, functions
- `stow/git/` - Git settings and aliases
- `stow/tmux/` - Tmux terminal multiplexer
- `stow/starship/` - Shell prompt styling
- `stow/ghostty/` - Ghostty terminal emulator

After editing any config:

```bash
cd ~/dotfiles
stow -R <package-name>  # Restow to pick up changes
```

### Adding New Packages

**macOS:**
```bash
# Add to packages/macos.txt
echo "your-package" >> packages/macos.txt

# Install
brew install your-package
```

**Linux:**
```bash
# Add to packages/linux.txt or packages/common.txt
echo "your-package" >> packages/common.txt

# Install with your package manager
apt install your-package  # Debian/Ubuntu
dnf install your-package  # Fedora
pacman -S your-package    # Arch
```

### Creating New Stow Packages

```bash
cd ~/dotfiles/stow
mkdir my-package
mkdir -p my-package/.config/my-app
echo "config content" > my-package/.config/my-app/config

# Install it
stow my-package
```

---

## Package Management Philosophy

**Global (System Package Manager):** Core tools used across all projects
- CLI utilities (ripgrep, fd, bat, eza, fzf)
- Development tools (git, tmux, neovim)
- Universal languages (Node.js LTS, Python 3)
- Installed via Homebrew (macOS) or apt/dnf/pacman (Linux)

**Project-specific (Devbox):** Project dependencies
- Specific language versions (Python 3.12, Go 1.21)
- Cloud CLIs (aws, gcloud, kubectl)
- Build tools, frameworks, databases

**Why?** Keep your global environment minimal and stable. Projects are self-contained and reproducible.

### Using Devbox for Projects

```bash
cd my-project
devbox init
devbox add python@3.12 poetry postgresql
devbox shell  # Enter isolated environment
```

Pre-configured templates in `project-templates/`:
- **Python** - Python 3.12, poetry, common tools
- **Node.js** - Node 20, pnpm, TypeScript
- **Go** - Go 1.21, common tools
- **Cloudflare** - Wrangler, Node.js for Workers
- **Kubernetes** - kubectl, k9s, helm
- **Infrastructure** - Terraform, Ansible, cloud CLIs

Copy a template:
```bash
cp -r ~/dotfiles/project-templates/python myproject/
cd myproject && devbox shell
```

---

## Troubleshooting

### Symlink Conflicts

**Error: "already exists and is not a symlink"**

Solution:
```bash
# Backup existing config
mv ~/.config/nvim ~/.config/nvim.backup

# Restow
cd ~/dotfiles/stow
stow nvim
```

### Programs Not Found After Install

**Restart your shell:**
```bash
exec zsh
```

**Check if Homebrew is in PATH (macOS):**
```bash
echo $PATH | grep homebrew
```

**Reload shell config:**
```bash
source ~/.zshrc
```

### Update Issues

**Update Homebrew packages (macOS):**
```bash
brew update
brew upgrade
```

**Update system packages (Linux):**
```bash
# Ubuntu/Debian
sudo apt update && sudo apt upgrade

# Fedora
sudo dnf upgrade

# Arch
sudo pacman -Syu
```

### Remove All Dotfiles

```bash
cd ~/dotfiles
./uninstall.sh
```

Or manually:
```bash
cd ~/dotfiles/stow
for pkg in */; do stow -D "${pkg%/}"; done
```

---

## Repository Structure

```
dotfiles/
├── install.sh             # Main installation script
├── stow-all.sh            # Stow all packages at once
├── uninstall.sh           # Remove all dotfiles
├── stow/                  # Dotfile packages (managed by Stow)
│   ├── nvim/              # Neovim config
│   ├── zsh/               # Zsh shell config
│   ├── git/               # Git config
│   ├── tmux/              # Tmux config
│   ├── starship/          # Starship prompt
│   ├── ghostty/           # Ghostty terminal
│   ├── navi/              # Navi cheatsheets
│   ├── opencode/          # OpenCode AI config
│   ├── ssh/               # SSH config
│   ├── fzf/               # FZF fuzzy finder
│   └── direnv/            # Direnv config
├── packages/              # Package lists
│   ├── common.txt         # Cross-platform packages
│   ├── macos.txt          # macOS-specific (Homebrew)
│   └── linux.txt          # Linux-specific
├── scripts/               # Utility scripts
│   ├── initial-setup.sh   # First-time setup
│   ├── setup-macos-initial.sh
│   ├── setup-linux-initial.sh
│   ├── setup-github-ssh.sh
│   ├── health-check.sh
│   ├── update.sh
│   └── lib/utils.sh
├── project-templates/     # Devbox templates
│   ├── python/
│   ├── nodejs/
│   ├── golang/
│   ├── cloudflare/
│   ├── infrastructure/
│   └── kubernetes/
├── claude/                # MCP server configs
├── docs/                  # Documentation
│   └── QUICK_REFERENCE.md
└── hosts/                 # Host-specific configs
    └── example-hostname/
```

---

## How Stow Works

GNU Stow creates symlinks from your home directory to files in the dotfiles repo:

```bash
# Before stow
~/dotfiles/stow/nvim/.config/nvim/init.lua  # Your actual file

# After running: stow nvim
~/.config/nvim/init.lua -> ~/dotfiles/stow/nvim/.config/nvim/init.lua  # Symlink
```

**Benefits:**
- Edit files directly in the repo
- Changes are immediately active
- Easy to version control
- Simple to understand and debug

---

## Philosophy

1. **Simple** - Symlinks, not complex abstractions
2. **Portable** - Works on any Unix-like system
3. **Transparent** - You can see exactly what's happening
4. **Maintainable** - Easy to add, remove, or modify configs
5. **Fast** - No build steps, no compilation

---

## Advanced

### Installing on a New Machine

```bash
# Quick install
git clone https://github.com/loidolt/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

### Selective Installation

```bash
# Install only specific packages
cd ~/dotfiles/stow
stow nvim zsh git tmux
```

### Host-Specific Overrides

Create host-specific configs in `hosts/$(hostname)/`:

```bash
mkdir -p ~/dotfiles/hosts/$(hostname)
echo "# Host-specific aliases" > ~/dotfiles/hosts/$(hostname)/host.sh
```

This file is automatically sourced by the Zsh configuration.

### Keeping Dotfiles Updated

```bash
cd ~/dotfiles
git pull
./stow-all.sh  # Restow all packages
./scripts/update.sh  # Update system packages
```

---

## License

See [LICENSE](LICENSE) for details.

## Contributing

This is a personal dotfiles repository, but feel free to fork and adapt for your own needs! If you find bugs or have suggestions, please open an issue.
