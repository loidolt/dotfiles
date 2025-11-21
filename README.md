# Dotfiles

A complete development machine bootstrap system with automated package installation and configuration management.

## Overview

This repository provides a **full-stack development environment setup** that includes:

### Configuration Files (Dotfiles)
- **OpenCode** - AI-powered code editor CLI
- **WezTerm** - GPU-accelerated terminal emulator
- **Neovim** - Modern text editor based on kickstart.nvim
- **Tmux** - Terminal multiplexer with truecolor support

### Automated Installation (New!)
- **Ansible automation** - Installs packages, languages, and tools
- **Bootstrap script** - One-command setup for new machines
- **Environment management** - Centralized configuration
- **Validation** - Post-install verification

## Repository Structure

```
dotfiles/
├── bootstrap.sh         # 🎬 Main entry point - run this first!
├── install.sh           # Dotfiles symlink script
├── uninstall.sh         # Remove symlinks
│
├── ansible/             # 📦 Automated installation
│   ├── setup.yml       # Main playbook
│   ├── ansible.cfg     # Ansible configuration
│   ├── inventory.yml   # Localhost inventory
│   ├── group_vars/     # Package lists and settings
│   │   └── all.yml    # Customize what gets installed
│   └── roles/          # Installation roles
│       ├── packages/   # Core packages & CLI tools
│       ├── languages/  # Node, Python, Go, etc.
│       ├── docker/     # Docker setup
│       ├── shell/      # ZSH plugins & prompt
│       └── applications/ # GUI apps (macOS)
│
├── scripts/            # 🔧 Helper scripts
│   ├── lib/
│   │   └── utils.sh   # Shared utilities
│   ├── env-setup.sh   # Environment variables
│   ├── ssh-setup.sh   # SSH configuration
│   └── validate.sh    # Post-install checks
│
├── opencode/           # OpenCode configuration
│   ├── opencode.json  # Main config with MCP servers
│   └── README.md
├── wezterm/            # WezTerm configuration
│   ├── wezterm.lua    # Terminal config
│   └── README.md
├── neovim/             # Neovim configuration
│   ├── init.lua       # Main init file
│   └── lua/           # Lua modules
├── tmux/               # Tmux configuration
│   ├── .tmux.conf     # Main config with truecolor
│   └── README.md
│
└── docs/               # 📚 Documentation
    └── SETUP.md       # Detailed setup guide
```

## Quick Start

### 🚀 New Machine Setup (Recommended)

**One command to set up everything:**

```bash
git clone https://github.com/yourusername/dotfiles.git ~/dotfiles
cd ~/dotfiles
./bootstrap.sh
```

This will:
1. ✅ Install Homebrew/apt package manager
2. ✅ Install Ansible for automation
3. ✅ Install packages (git, curl, ripgrep, etc.)
4. ✅ Install languages (Node.js, Bun, etc.)
5. ✅ Setup Docker
6. ✅ Install shell enhancements (oh-my-zsh, starship)
7. ✅ Install GUI applications (optional)
8. ✅ Symlink dotfiles configurations
9. ✅ Setup environment variables
10. ✅ Validate installation

**Interactive mode** - Choose what to install:
```bash
./bootstrap.sh
```

**Quick options:**
```bash
./bootstrap.sh --full           # Install everything
./bootstrap.sh --minimal        # Core packages + dotfiles only
./bootstrap.sh --dotfiles-only  # Just symlink configs
./bootstrap.sh --dry-run        # See what would be installed
```

### 📋 Dotfiles Only (Existing System)

If you already have packages installed and just want the configurations:

```bash
cd ~/dotfiles
./install.sh
```

This will:
- Create symbolic links for OpenCode, WezTerm, and Neovim configs
- Backup any existing configurations with timestamps
- Set up all configurations automatically

### 🧹 Uninstallation

To remove the symlinks:
```bash
./uninstall.sh
```

## What Gets Installed

### Core Packages
- git, curl, wget, vim, tmux, htop, tree, jq

### Modern CLI Tools
- **ripgrep** - Fast search
- **fd** - Fast find
- **bat** - Better cat
- **fzf** - Fuzzy finder
- **eza** - Modern ls
- **zoxide** - Smart cd

### Languages & Runtimes
- **mise** - Universal version manager
- **Node.js 20** (LTS)
- **Bun** - Fast JavaScript runtime
- Python, Go, Rust (optional)

### Development Tools
- **Docker** & Docker Desktop
- **oh-my-zsh** with plugins
- **Starship** prompt

### GUI Apps (macOS)
- VS Code, Chrome, Slack, 1Password, Rectangle

See [`ansible/group_vars/all.yml`](ansible/group_vars/all.yml) for the complete list.

## Customization

### Change What Gets Installed

Edit [`ansible/group_vars/all.yml`](ansible/group_vars/all.yml):

```yaml
packages:
  core:
    - git
    - your-package-here
  
languages:
  install_node: true
  node_version: "20"
  
applications:
  apps:
    - visual-studio-code
    - your-app
```

Then re-run:
```bash
cd ansible
ansible-playbook setup.yml --tags packages
```

## Post-Installation

### 1. Configure API Keys

Edit `~/.dotfiles_env` and add your actual API keys:
```bash
nvim ~/.dotfiles_env
```

### 2. Restart Terminal

```bash
source ~/.zshrc
# Or restart your terminal
```

### 3. Validate Installation

```bash
./scripts/validate.sh
```

### 4. Setup SSH (Optional)

```bash
./scripts/ssh-setup.sh
```

## Advanced Usage

### Run Specific Installation Tasks

```bash
cd ansible

# Install only packages
ansible-playbook setup.yml --tags packages

# Install only languages  
ansible-playbook setup.yml --tags languages

# Install Docker
ansible-playbook setup.yml --tags docker

# Dry run (see what would change)
ansible-playbook setup.yml --check --diff
```

### Update Packages

```bash
cd ~/dotfiles
git pull
cd ansible
ansible-playbook setup.yml
```

### Manual Symlinks

If you prefer manual installation:

```bash
ln -s ~/dotfiles/opencode ~/.config/opencode
ln -s ~/dotfiles/wezterm ~/.config/wezterm
ln -s ~/dotfiles/neovim ~/.config/nvim
```

## Configuration Details

### OpenCode
- MCP servers configured: context7, sequentialthinking, memory, playwright, github
- Theme: Catppuccin
- **Note**: For themes to work in tmux, see [docs/OPENCODE_TMUX_FIX.md](docs/OPENCODE_TMUX_FIX.md)
- See `opencode/README.md` for more details

### WezTerm
- Color scheme: Catppuccin Mocha
- Font size: 10
- Window size: 120x28
- See `wezterm/README.md` for more details

### Neovim
- Based on kickstart.nvim
- Plugin manager: lazy.nvim
- Includes LSP, Treesitter, and more
- See `neovim/README.md` for more details

## Documentation

- **[README.md](README.md)** - This file (overview and quick start)
- **[docs/SETUP.md](docs/SETUP.md)** - Detailed setup guide
- **[ansible/group_vars/all.yml](ansible/group_vars/all.yml)** - Package configuration
- **Individual tool docs:**
  - [opencode/README.md](opencode/README.md) - OpenCode configuration
  - [wezterm/README.md](wezterm/README.md) - WezTerm configuration
  - [neovim/README.md](neovim/README.md) - Neovim configuration
  - [tmux/README.md](tmux/README.md) - Tmux configuration
- **[docs/OPENCODE_TMUX_FIX.md](docs/OPENCODE_TMUX_FIX.md)** - Fix for OpenCode themes in tmux

## Best Practices

- **Security**: Avoid committing sensitive data like API keys
  - Use environment variables when possible
  - Add sensitive files to `.gitignore`
  
- **Backups**: The install script automatically backs up existing configs

- **Testing**: Test on a fresh system or VM before relying on these configs

- **Documentation**: Keep README files updated when making changes

## How It Works

### Symlinks (Not Copies!)

Your configurations are **symlinked** from this repository to their destination:
- `~/dotfiles/opencode` → `~/.config/opencode` (symlink)
- `~/dotfiles/wezterm` → `~/.config/wezterm` (symlink)
- `~/dotfiles/neovim` → `~/.config/nvim` (symlink)

**This means:**
- ✅ Edit files in `~/dotfiles/` and changes apply immediately
- ✅ Open `~/dotfiles` in VS Code to manage all configs
- ✅ `git pull` updates your live configs instantly
- ✅ Changes in `~/.config/` are changes in the repo

### Architecture

```
bootstrap.sh (orchestrator)
    ↓
Install Homebrew/apt
    ↓
Install Ansible
    ↓
Run Ansible Playbook (packages, languages, docker, shell, apps)
    ↓
Run install.sh (symlink dotfiles)
    ↓
Run env-setup.sh (environment variables)
    ↓
Run validate.sh (verify installation)
```

### Technologies Used

- **Bash** - Orchestration and glue scripts
- **Ansible** - Declarative package management
- **Symlinks** - Config file management
- **mise** - Language version management
- **Homebrew/apt** - Package installation

## Troubleshooting

### Run Validation First
```bash
./scripts/validate.sh
```

### Common Issues

**Homebrew not found (macOS ARM)**
```bash
eval "$(/opt/homebrew/bin/brew shellenv)"
```

**Ansible fails on macOS**
```bash
xcode-select --install
```

**Node/Bun not found**
```bash
source ~/.dotfiles_env
# Or restart terminal
```

**Docker permission denied (Linux)**
```bash
newgrp docker  # Or log out/in
```

**Symlinks not working**
```bash
chmod +x install.sh
ls -la ~/.config/opencode  # Check symlink
```

**OpenCode theme not working in tmux**
```bash
# See docs/OPENCODE_TMUX_FIX.md for detailed fix
tmux kill-server  # Restart tmux
tmux
```

**API keys not working**
```bash
nvim ~/.dotfiles_env  # Add actual keys
source ~/.dotfiles_env
```

See [docs/SETUP.md](docs/SETUP.md) for detailed troubleshooting.

## Features

✨ **One-command setup** - Fresh machine to ready-to-code in minutes  
🔧 **Idempotent** - Safe to run multiple times  
🎯 **Customizable** - Easy to add/remove packages  
🔄 **Cross-platform** - macOS and Linux support  
📦 **Modern tools** - Latest CLIs and dev tools  
🔒 **Secure** - API keys in environment, not committed  
📝 **Well-documented** - Comprehensive guides  
✅ **Validated** - Post-install verification  

## Philosophy

This dotfiles system follows these principles:

1. **Transparency** - Symlinks, not copies. See exactly what's happening.
2. **Simplicity** - Bash + Ansible. Standard, proven tools.
3. **Modularity** - Each component independent and reusable.
4. **Flexibility** - Run full setup or specific parts.
5. **Documentation** - Every script, every role, documented.
6. **Safety** - Backups, validation, dry-run support.

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