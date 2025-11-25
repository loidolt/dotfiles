# Development Machine Setup Guide

Complete guide for setting up a new development machine using these dotfiles.

## Quick Start

```bash
# Clone this repository
git clone https://github.com/yourusername/dotfiles.git ~/dotfiles
cd ~/dotfiles

# Run the bootstrap script
./bootstrap.sh
```

That's it! The script will guide you through the setup process.

## What Gets Installed

### Core Packages
- **git, curl, wget** - Essential utilities
- **vim, tmux** - Terminal tools
- **htop, tree, jq** - System utilities

### Modern CLI Tools
- **ripgrep (rg)** - Fast grep alternative
- **fd** - Fast find alternative
- **bat** - Cat with syntax highlighting
- **fzf** - Fuzzy finder
- **eza** - Modern ls replacement
- **zoxide** - Smart directory jumping

### Programming Languages & Runtimes
- **mise** - Version manager (replaces nvm, rbenv, etc.)
- **Node.js 20** (LTS) via mise
- **Bun** - Fast JavaScript runtime
- **Python, Go, Rust** (optional)

### Development Tools
- **Docker** & Docker Desktop (macOS)
- **GitHub CLI (gh)** - GitHub from terminal
- **Starship** - Beautiful shell prompt

### Shell Enhancements
- **oh-my-zsh** - ZSH framework
- **zsh-autosuggestions** - Command suggestions
- **zsh-syntax-highlighting** - Syntax highlighting

### GUI Applications (macOS)
- **VS Code** - Code editor
- **Chrome/Firefox** - Browsers
- **Slack/Discord** - Communication
- **1Password** - Password manager
- **Rectangle** - Window management

### Fonts
- **Nerd Fonts** - Fonts with icons for terminal

## Installation Options

### Full Setup
```bash
./bootstrap.sh --full
```
Installs everything: packages, languages, Docker, GUI apps, dotfiles.

### Minimal Setup
```bash
./bootstrap.sh --minimal
```
Installs only core packages and dotfiles. No languages, Docker, or GUI apps.

### Dotfiles Only
```bash
./bootstrap.sh --dotfiles-only
```
Only creates symlinks for configuration files.

### Dry Run
```bash
./bootstrap.sh --dry-run
```
Shows what would be installed without making changes.

### Interactive
```bash
./bootstrap.sh
```
Presents a menu to choose what to install.

## Post-Installation Steps

### 1. Configure API Keys

Edit the environment file:
```bash
nvim ~/.dotfiles_env
```

Replace placeholder values with your actual API keys:
- `REF_API_KEY` - Get from https://ref.tools
- `CONTEXT7_API_KEY` - Get from https://context7.com

### 2. Restart Terminal

```bash
# Reload shell configuration
source ~/.zshrc

# Or restart your terminal app
```

### 3. Verify Installation

```bash
./scripts/validate.sh
```

This checks that everything is installed correctly.

### 4. Setup SSH Keys (Optional)

```bash
./scripts/ssh-setup.sh
```

Generates SSH keys and configures them for GitHub.

## Customization

### Change Installed Packages

Edit `ansible/group_vars/all.yml`:

```yaml
packages:
  core:
    - git
    - your-package-here
  
  cli_tools:
    - ripgrep
    - your-cli-tool
```

Then re-run:
```bash
cd ~/dotfiles/ansible
ansible-playbook setup.yml --tags packages
```

### Add New Language Versions

```yaml
languages:
  install_node: true
  node_version: "20"  # Change version
  
  install_python: true  # Enable Python
  python_version: "3.11"
```

### Install Additional GUI Apps

```yaml
applications:
  apps:
    - visual-studio-code
    - your-app-here
```

## Directory Structure

```
dotfiles/
├── bootstrap.sh           # Main entry point
├── install.sh             # Dotfiles symlink script
├── uninstall.sh           # Remove symlinks
│
├── ansible/               # Automation
│   ├── setup.yml         # Main playbook
│   ├── ansible.cfg       # Ansible config
│   ├── inventory.yml     # Localhost inventory
│   ├── group_vars/       # Variables
│   │   └── all.yml      # Package lists
│   └── roles/            # Ansible roles
│       ├── packages/    # System packages
│       ├── languages/   # Node, Python, etc.
│       ├── docker/      # Docker setup
│       ├── shell/       # Shell tools
│       └── applications/ # GUI apps
│
├── scripts/              # Helper scripts
│   ├── lib/
│   │   └── utils.sh     # Shared functions
│   ├── env-setup.sh     # Environment variables
│   ├── ssh-setup.sh     # SSH configuration
│   └── validate.sh      # Post-install validation
│
├── opencode/            # Your existing configs
├── neovim/              # Your existing configs
│
└── docs/                # Documentation
    └── SETUP.md         # This file
```

## Running Specific Tasks

### Install Only Packages
```bash
cd ansible
ansible-playbook setup.yml --tags packages
```

### Install Only Languages
```bash
cd ansible
ansible-playbook setup.yml --tags languages
```

### Install Docker
```bash
cd ansible
ansible-playbook setup.yml --tags docker
```

### Update Dotfiles
```bash
cd ~/dotfiles
git pull
./install.sh
```

## Troubleshooting

### Homebrew Not Found (macOS ARM)

If running on Apple Silicon and Homebrew isn't found:
```bash
eval "$(/opt/homebrew/bin/brew shellenv)"
```

Then add to your `~/.zshrc`:
```bash
eval "$(/opt/homebrew/bin/brew shellenv)"
```

### Ansible Fails on macOS

Make sure Xcode Command Line Tools are installed:
```bash
xcode-select --install
```

### Permission Errors on Linux

Some tasks require sudo. The script will prompt when needed:
```bash
sudo ./bootstrap.sh
```

### Node/Bun Not Found After Install

The environment needs to be reloaded:
```bash
source ~/.dotfiles_env
# Or restart terminal
```

### Docker Permission Denied (Linux)

After Docker installation, log out and back in for group changes to take effect:
```bash
newgrp docker
```

Or restart your session.

## Manual Installation Steps

Some things must be done manually:

### System Preferences (macOS)
- Keyboard repeat rate: System Preferences → Keyboard → Delay/Repeat
- Trackpad gestures: System Preferences → Trackpad
- Hot corners: System Preferences → Desktop & Screen Saver

### Application Logins
- Sign into Chrome/Firefox (sync bookmarks)
- Sign into VS Code (sync settings)
- Sign into Slack workspaces
- Configure 1Password

### Project Repositories
```bash
# Clone your work projects
cd ~/Projects
git clone git@github.com:org/repo.git
```

## Advanced Usage

### Running Ansible Directly

You can run Ansible playbooks directly for more control:

```bash
cd ~/dotfiles/ansible

# Check mode (dry run)
ansible-playbook setup.yml --check --diff

# Run specific role
ansible-playbook setup.yml --tags packages

# Skip specific role
ansible-playbook setup.yml --skip-tags applications

# Verbose output
ansible-playbook setup.yml -v
```

### Updating Packages

To update all installed packages:

**macOS:**
```bash
brew update && brew upgrade
```

**Linux:**
```bash
sudo apt update && sudo apt upgrade
```

### Adding Your Own Scripts

1. Create script in `scripts/`:
```bash
touch scripts/my-setup.sh
chmod +x scripts/my-setup.sh
```

2. Source utilities:
```bash
#!/usr/bin/env bash
source "$(dirname "$0")/lib/utils.sh"

section "My Setup"
info "Doing something..."
success "Done!"
```

3. Call from `bootstrap.sh` if needed.

## Keeping Dotfiles Updated

### Pull Latest Changes
```bash
cd ~/dotfiles
git pull
```

### Update Packages
```bash
cd ~/dotfiles/ansible
ansible-playbook setup.yml --tags packages
```

### Re-run Full Setup
```bash
cd ~/dotfiles
./bootstrap.sh --full
```

The scripts are idempotent - safe to run multiple times!

## Backing Up Your Configuration

Before major changes:
```bash
cd ~/dotfiles
git status          # Check what's changed
git add .
git commit -m "Backup before changes"
git push
```

## Getting Help

- Check `README.md` for overview
- Check this file for detailed setup
- Check `ansible/group_vars/all.yml` for configuration options
- Run `./scripts/validate.sh` to diagnose issues
- Check individual script files for inline documentation

## Security Notes

- Never commit real API keys to git
- Use `~/.dotfiles_env` for secrets (not tracked)
- SSH private keys stay local (never copy between machines)
- Use password manager for sensitive credentials

## Next Steps

After setup:
1. Customize shell prompt (edit Starship config)
2. Add your favorite VS Code extensions
3. Configure Git globally (`git config --global user.name "..."`)
4. Explore Neovim plugins

Enjoy your new development environment! 🚀
