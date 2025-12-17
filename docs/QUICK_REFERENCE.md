# Quick Reference Guide

## Dotfiles Management

### Stow Commands

```bash
# Install all configurations
cd ~/dotfiles
./stow-all.sh

# Install specific package
cd ~/dotfiles/stow
stow nvim        # Install neovim config
stow zsh         # Install zsh config
stow git         # Install git config

# Uninstall specific package
stow -D nvim     # Remove neovim symlinks

# Reinstall (useful after updates)
stow -R nvim     # Restow neovim config

# List what would be stowed (dry run)
stow -n -v nvim
```

### Maintenance

```bash
# Run health check
cd ~/dotfiles
./scripts/health-check.sh

# Update system packages
./scripts/update.sh

# Update dotfiles from repo
git pull
./stow-all.sh

# Uninstall everything
./uninstall.sh
```

### Package Management

**macOS (Homebrew):**
```bash
brew update              # Update package list
brew upgrade             # Upgrade all packages
brew search <name>       # Search for package
brew install <name>      # Install package
brew list                # List installed packages
brew info <name>         # Package information
```

**Ubuntu/Debian:**
```bash
sudo apt update          # Update package list
sudo apt upgrade         # Upgrade packages
sudo apt search <name>   # Search for package
sudo apt install <name>  # Install package
```

**Fedora:**
```bash
sudo dnf upgrade         # Update packages
sudo dnf search <name>   # Search for package
sudo dnf install <name>  # Install package
```

**Arch:**
```bash
sudo pacman -Syu         # Update packages
sudo pacman -Ss <name>   # Search for package
sudo pacman -S <name>    # Install package
```

---

## Common Commands

### Tmux (Ctrl-b prefix)

```bash
# Session management
tmux new -s myname       # New named session
tmux attach -t myname    # Attach to session
tmux ls                  # List sessions
tmux kill-session -t myname  # Kill session
```

**Key Bindings:**
- `Ctrl-b %` - Split pane vertically
- `Ctrl-b "` - Split pane horizontally
- `Ctrl-b o` - Switch to next pane
- `Ctrl-b c` - Create new window
- `Ctrl-b n` - Next window
- `Ctrl-b p` - Previous window
- `Ctrl-b d` - Detach from session

### Git Aliases

```bash
gs      # git status
gc      # git commit
gp      # git push
gl      # git pull
gd      # git diff
gco     # git checkout
glog    # git log --oneline --graph
```

### Modern CLI Tools

```bash
# eza (better ls)
ls      # eza --icons
ll      # eza -la --icons
la      # eza -a --icons
lt      # eza --tree --icons

# bat (better cat)
cat <file>  # Uses bat with syntax highlighting

# ripgrep (better grep)
rg <pattern>
rg -i <pattern>  # Case insensitive
rg -l <pattern>  # List files only

# fd (better find)
fd <pattern>
fd -e js         # Find .js files
fd -H <pattern>  # Include hidden files

# zoxide (smart cd)
z <directory-name>
zi               # Interactive directory selection

# fzf (fuzzy finder)
Ctrl-R  # Search command history
Ctrl-T  # Search files
Alt-C   # Change directory
```

---

## File Locations

### Dotfiles Structure

```
~/dotfiles/
├── stow/              # All configuration files
│   ├── nvim/          # → ~/.config/nvim/
│   ├── zsh/           # → ~/.zshrc, etc.
│   ├── git/           # → ~/.gitconfig
│   ├── tmux/          # → ~/.tmux.conf
│   ├── starship/      # → ~/.config/starship.toml
│   ├── ghostty/       # → ~/.config/ghostty/
│   └── opencode/      # → ~/.config/opencode/
├── scripts/           # Utility scripts
├── packages/          # Package lists
└── project-templates/ # Devbox templates
```

### Configuration Files (After Stowing)

- Neovim: `~/.config/nvim/` → `~/dotfiles/stow/nvim/.config/nvim/`
- Zsh: `~/.zshrc` → `~/dotfiles/stow/zsh/.zshrc`
- Git: `~/.gitconfig` → `~/dotfiles/stow/git/.gitconfig`
- Tmux: `~/.tmux.conf` → `~/dotfiles/stow/tmux/.tmux.conf`
- Starship: `~/.config/starship.toml` → `~/dotfiles/stow/starship/.config/starship.toml`
- Ghostty: `~/.config/ghostty/` → `~/dotfiles/stow/ghostty/.config/ghostty/`
- OpenCode: `~/.config/opencode/` → `~/dotfiles/stow/opencode/.config/opencode/`

---

## Keyboard Shortcuts

### Zsh

- `Ctrl-R` - Search command history (with fzf)
- `Ctrl-T` - Search files (with fzf)
- `Alt-C` - Change directory (with fzf)
- `Tab` - Auto-complete with suggestions
- `Ctrl-A` - Jump to beginning of line
- `Ctrl-E` - Jump to end of line

### Neovim (Custom)

See [stow/nvim/.config/nvim/KEYBINDINGS.md](../stow/nvim/.config/nvim/KEYBINDINGS.md) for full list.

---

## Quick Edits

```bash
# Edit specific dotfiles
nvim ~/dotfiles/stow/zsh/.zshrc
nvim ~/dotfiles/stow/git/.gitconfig
nvim ~/dotfiles/stow/nvim/.config/nvim/init.lua
nvim ~/dotfiles/stow/tmux/.tmux.conf

# After editing, restow to apply changes
cd ~/dotfiles/stow
stow -R zsh    # Or whichever package you edited

# Or just restart your shell for zsh changes
exec zsh
```

---

## Devbox Project Workflows

```bash
# Create new project from template
cp -r ~/dotfiles/project-templates/python myproject/
cd myproject
devbox shell

# Or start fresh
devbox init
devbox add python@3.12 poetry
devbox shell

# Common Devbox commands
devbox shell           # Enter isolated environment
devbox run <script>    # Run script in devbox
devbox services start  # Start services
devbox services stop   # Stop services
```

---

## Troubleshooting

### Symlink Issues

```bash
# Check if config is properly symlinked
ls -la ~/.config/nvim
ls -la ~/.zshrc

# Remove broken symlinks
find ~ -xtype l -delete

# Restow package
cd ~/dotfiles/stow
stow -D nvim  # Unlink
stow nvim     # Relink
```

### Shell Not Loading Config

```bash
# Verify zsh config location
which zsh
echo $SHELL

# Reload zsh config
source ~/.zshrc

# Or restart shell
exec zsh
```

### Package Not Found

```bash
# macOS: Update Homebrew
brew update

# Check if package is installed
which <package>

# Reinstall if needed
brew reinstall <package>  # macOS
```

---

## Resources

- [Main README](../README.md)
- [GNU Stow Manual](https://www.gnu.org/software/stow/manual/)
- [Homebrew Formulae](https://formulae.brew.sh/)
- [Devbox Documentation](https://www.jetpack.io/devbox/docs/)
