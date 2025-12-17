# Dotfiles

> Cross-platform dotfiles using Nix and Home Manager

**Quick Navigation:** [Quick Start](#quick-start) | [Daily Usage](#daily-usage) | [Customization](#customization) | [Troubleshooting](#troubleshooting)

## Features

- 🔄 Reproducible dev environment across macOS and Linux
- 📦 100+ CLI tools managed declaratively  
- ⚡ Fast rebuilds with Nix flakes
- 🔙 Rollback to any previous generation
- 🎯 Project-specific environments with Devbox

---

## Quick Start

### Prerequisites

- macOS (ARM/Intel) or Linux (x86/WSL2)
- 30 minutes for initial setup
- Internet connection

### Installation

**Step 1: Bootstrap Nix** (5-10 minutes)

```bash
git clone https://github.com/loidolt/dotfiles.git ~/dotfiles
cd ~/dotfiles
bash scripts/initial-setup.sh
```

**Important:** Close your terminal and open a new one after this step.

**Step 2: Install Dotfiles** (10-20 minutes)

```bash
cd ~/dotfiles
bash scripts/install-dotfiles.sh
```

**That's it!** Your environment is ready.

---

## Daily Usage

### Rebuilding After Changes

```bash
# Apply configuration changes
hm

# Update packages
hm-update

# Verify setup
hm-validate

# Run health check
hm-health
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

[Full package list in home/packages.nix](home/packages.nix)

---

## Customization

### Adding Packages

Edit `home/packages.nix`:

```nix
home.packages = with pkgs; [
  # Add your packages here
  your-package-name
];
```

Search for packages:
```bash
nix search nixpkgs <package-name>
```

Apply changes:
```bash
hm
```

### Modifying Program Configs

Program configurations live in `home/programs/`:

- `zsh.nix` - Shell configuration, aliases, functions
- `git.nix` - Git settings and aliases
- `neovim.nix` - Editor packages and LSP servers
- `tmux.nix` - Terminal multiplexer settings
- `starship.nix` - Prompt styling and modules

After editing any config, run `hm` to apply changes.

### User Configuration

Edit `user.nix` to customize:

```nix
{
  username = "yourname";
  
  git = {
    name = "Your Name";
    email = "your.email@example.com";
  };
}
```

---

## Package Management Philosophy

**Global (Nix):** Core tools used across all projects
- CLI utilities (ripgrep, fd, bat, eza)
- Development tools (git, tmux, neovim)
- Universal languages (Node.js LTS, Python 3)

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

### Build Fails

**Check syntax errors:**
```bash
nix flake check
```

**Build with detailed trace:**
```bash
nix build .#homeConfigurations.default.activationPackage --show-trace --impure
```

**Common build errors:**

- **"experimental features not enabled"**  
  → Re-run setup scripts, they configure flakes support

- **"builder for ... failed"**  
  → Check internet connection, try `nix flake update`

- **"collision between ... and ..."**  
  → Duplicate packages in packages.nix, remove one

### Programs Not Found After Install

**Restart your shell:**
```bash
exec $SHELL
```

**Check PATH includes Nix:**
```bash
echo $PATH | grep nix-profile
```

**Re-apply configuration:**
```bash
hm
```

### Rollback to Previous Version

If a change breaks something, you can rollback instantly:

```bash
# List all generations
home-manager generations

# Activate a previous generation
/nix/store/HASH-home-manager-generation/activate
```

### Nix Daemon Issues (Linux)

**Check daemon status:**
```bash
systemctl status nix-daemon
```

**Restart daemon:**
```bash
sudo systemctl restart nix-daemon
sudo systemctl enable nix-daemon
```

**Verify group membership:**
```bash
groups | grep nix-users
```

If not in nix-users group:
```bash
sudo usermod -aG nix-users $(whoami)
# Log out and back in
```

### Update Fails

**Update flake inputs:**
```bash
cd ~/dotfiles
nix flake update
hm
```

**Clear old generations (free up space):**
```bash
# Remove generations older than 30 days
nix-collect-garbage --delete-older-than 30d

# Or remove all old generations
nix-collect-garbage -d
```

---

## Repository Structure

```
dotfiles/
├── flake.nix              # Nix flake entry point
├── flake.lock             # Locked dependency versions
├── user.nix               # Your user configuration
├── home/
│   ├── default.nix        # Main home configuration
│   ├── packages.nix       # Package list
│   ├── dotfiles.nix       # Environment variables
│   └── programs/          # Program-specific configs
│       ├── zsh.nix
│       ├── git.nix
│       ├── neovim.nix
│       ├── tmux.nix
│       ├── starship.nix
│       ├── fzf.nix
│       ├── direnv.nix
│       ├── navi.nix
│       └── ssh.nix
├── configs/
│   ├── neovim/            # Neovim config (Lua)
│   ├── opencode/          # OpenCode AI config
│   ├── ghostty/           # Ghostty terminal config
│   └── navi/cheats/       # Command cheatsheets
├── project-templates/     # Devbox project templates
│   ├── python/
│   ├── nodejs/
│   ├── golang/
│   ├── cloudflare/
│   ├── infrastructure/
│   └── kubernetes/
├── scripts/               # Setup & maintenance scripts
│   ├── initial-setup.sh
│   ├── install-dotfiles.sh
│   ├── update.sh
│   ├── health-check.sh
│   └── validate-nix.sh
└── docs/
    └── QUICK_REFERENCE.md # Command cheatsheet
```

---

## Philosophy

1. **Declarative** - Describe what you want, Nix handles how
2. **Reproducible** - Same config = same result, always
3. **Atomic** - Changes are all-or-nothing, no partial states
4. **Rollback** - Revert to any previous state instantly
5. **Minimal** - Home Manager only, no system-level complexity

---

## Advanced

### Manual Installation

If automated scripts don't work, you can install manually:

**macOS:**
```bash
# Install Nix
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install

# Clone dotfiles
git clone https://github.com/loidolt/dotfiles.git ~/dotfiles

# Install with Home Manager
nix run home-manager/master -- switch --flake ~/dotfiles --impure

# Install fonts via Homebrew
brew install --cask font-fira-code-nerd-font font-jetbrains-mono-nerd-font font-meslo-lg-nerd-font
```

**Linux:**
```bash
# Install Nix
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install

# Clone dotfiles
git clone https://github.com/loidolt/dotfiles.git ~/dotfiles

# Install with Home Manager
nix run home-manager/master -- switch --flake ~/dotfiles --impure
```

### Updating Flake Inputs

```bash
# Update all inputs (nixpkgs, home-manager)
cd ~/dotfiles
nix flake update

# Update specific input
nix flake lock --update-input nixpkgs

# Rebuild with new inputs
hm
```

### Building for Different Platforms

The flake auto-detects your platform, but you can explicitly target others:

```bash
# Build for specific platform
home-manager switch --flake ~/dotfiles#aarch64-darwin --impure
home-manager switch --flake ~/dotfiles#x86_64-linux --impure
```

Available targets: `aarch64-darwin`, `x86_64-darwin`, `x86_64-linux`, `aarch64-linux`

---

## License

See [LICENSE](LICENSE) for details.

## Contributing

This is a personal dotfiles repository, but feel free to fork and adapt for your own needs! If you find bugs or have suggestions, please open an issue.
