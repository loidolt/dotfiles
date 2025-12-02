# Quick Reference Guide

## Common Commands

### Home Manager

```bash
# Rebuild and switch (use alias)
hm

# Or full command
home-manager switch --flake ~/Documents/GitHub/dotfiles#chrisloidolt --impure

# Linux version
home-manager switch --flake ~/dotfiles#chrisloidolt-linux --impure

# List all generations
home-manager generations

# Rollback to previous generation
/nix/store/HASH-home-manager-generation/activate
```

### Nix Package Management

```bash
# Update all packages
cd ~/Documents/GitHub/dotfiles
nix flake update
hm

# Search for packages
nix search nixpkgs <package-name>

# Check flake configuration
nix flake show
nix flake check

# Clean old generations
nix-collect-garbage --delete-older-than 30d

# Optimize Nix store
nix-store --optimise
```

### Tmux

```bash
# New named session
tmux new -s myname

# Attach to session
tmux attach -t myname

# List sessions
tmux ls

# Kill session
tmux kill-session -t myname
```

### Git Aliases

```bash
gs      # git status
gc      # git commit
gp      # git push
gl      # git pull
gd      # git diff
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

# fd (better find)
fd <pattern>

# zoxide (smart cd)
z <directory-name>

# fzf (fuzzy finder)
Ctrl-R  # Search command history
Ctrl-T  # Search files
```

---

## File Locations

### Configurations

- Dotfiles repo: `~/Documents/GitHub/dotfiles` (macOS) or `~/dotfiles` (Linux)
- Neovim: `~/.config/nvim/` (symlinked)
- OpenCode: `~/.config/opencode/` (symlinked)
- Ghostty: `~/.config/ghostty/` (symlinked)
- Tmux: `~/.tmux.conf` (managed by Home Manager)
- Zsh: `~/.zshrc` (managed by Home Manager)

### Nix Files

- Flake: `flake.nix`
- User config: `user.nix`
- Packages: `home/packages.nix`
- Program configs: `home/programs/`

---

## Keyboard Shortcuts

### Tmux (Ctrl-b prefix)

- `%` - Split pane vertically
- `"` - Split pane horizontally
- `o` - Switch to next pane
- `c` - Create new window
- `n` - Next window
- `p` - Previous window
- `d` - Detach from session

### Zsh

- `Ctrl-R` - Search command history (with fzf)
- `Ctrl-T` - Search files (with fzf)
- `Alt-C` - Change directory (with fzf)

---

## Quick Edits

```bash
# Edit package list
nvim ~/Documents/GitHub/dotfiles/home/packages.nix

# Edit zsh config
nvim ~/Documents/GitHub/dotfiles/home/programs/zsh.nix

# Rebuild after changes
hm
```

---

## Resources

- [Main README](../README.md)
- [Setup Guide](SETUP.md)
- [Troubleshooting](TROUBLESHOOTING.md)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [Nix Package Search](https://search.nixos.org/packages)
