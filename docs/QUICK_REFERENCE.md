# Quick Reference Guide

## Common Commands

### Home Manager

```bash
# Rebuild and switch
home-manager switch --flake ~/Documents/GitHub/dotfiles#chrisloidolt

# Rebuild with uncommitted changes
home-manager switch --flake ~/Documents/GitHub/dotfiles#chrisloidolt --impure

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
home-manager switch --flake .#chrisloidolt

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
# Reload config
tmux source ~/.tmux.conf

# Restart tmux server
tmux kill-server

# New named session
tmux new -s myname

# Attach to session
tmux attach -t myname

# List sessions
tmux ls
```

### Git

```bash
# Common shortcuts (from zsh aliases)
gs      # git status
ga      # git add
gc      # git commit
gp      # git push
gl      # git pull
gd      # git diff
lg      # lazygit
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

- Dotfiles repo: `~/Documents/GitHub/dotfiles`
- Neovim: `~/.config/nvim/` → symlinked to `~/Documents/GitHub/dotfiles/configs/neovim/`
- OpenCode: `~/.config/opencode/` → symlinked to `~/Documents/GitHub/dotfiles/configs/opencode/`
- Tmux: `~/.tmux.conf` (managed by Home Manager)
- Zsh: `~/.zshrc` (managed by Home Manager)

### Nix Files

- Home Manager config: `~/Documents/GitHub/dotfiles/home/`
- Flake: `~/Documents/GitHub/dotfiles/flake.nix`
- Packages: `~/Documents/GitHub/dotfiles/home/packages.nix`
- Program configs: `~/Documents/GitHub/dotfiles/home/programs/`

---

## Troubleshooting

### Check Installation

```bash
# Verify programs are from Nix
which nvim
which tmux
which git
# All should show /nix/store/... paths

# Check Home Manager generation
home-manager generations
```

### Fix Tmux Colors

```bash
# Verify truecolor config is loaded
tmux show-options -g -s | grep terminal

# Should see:
# terminal-features* "...:RGB"
# terminal-overrides* "...:Tc"

# Restart tmux completely
tmux kill-server && tmux

# Test colors
echo $TERM        # Should be: tmux-256color
echo $COLORTERM   # Should be: truecolor
```

### Reload Shell

```bash
source ~/.zshrc
# or
exec zsh
```

---

## Useful Checks

### Verify Truecolor Support

```bash
# Test color gradient (should show smooth colors)
awk 'BEGIN{
    s="/\\/\\/\\/\\/\\"; s=s s s s s s s s;
    for (colnum = 0; colnum<77; colnum++) {
        r = 255-(colnum*255/76);
        g = (colnum*510/76);
        b = (colnum*255/76);
        if (g>255) g = 510-g;
        printf "\033[48;2;%d;%d;%dm", r,g,b;
        printf "\033[38;2;%d;%d;%dm", 255-r,255-g,255-b;
        printf "%s\033[0m", substr(s,colnum+1,1);
    }
    printf "\n";
}'
```

### Check Installed Packages

```bash
# List all Nix packages
nix-env -q

# Check specific program version
nvim --version
tmux -V
git --version
```

---

## Quick Edits

### Edit Dotfiles

```bash
# Open in editor
nvim ~/Documents/GitHub/dotfiles

# Edit specific configs
nvim ~/Documents/GitHub/dotfiles/home/packages.nix
nvim ~/Documents/GitHub/dotfiles/home/programs/zsh.nix
nvim ~/Documents/GitHub/dotfiles/configs/opencode/opencode.json
```

### Update Package Lists

```bash
# Edit package list
nvim ~/Documents/GitHub/dotfiles/home/packages.nix

# Rebuild
home-manager switch --flake ~/Documents/GitHub/dotfiles#chrisloidolt
```

---

## Git Workflow

### Update Dotfiles

```bash
cd ~/Documents/GitHub/dotfiles
git pull
home-manager switch --flake .#chrisloidolt
```

### Commit Changes

```bash
cd ~/Documents/GitHub/dotfiles
git add .
git commit -m "Update configuration"
git push
```

---

## Keyboard Shortcuts

### Tmux

- `Ctrl-b %` - Split pane vertically
- `Ctrl-b "` - Split pane horizontally
- `Ctrl-b o` - Switch to next pane
- `Ctrl-b c` - Create new window
- `Ctrl-b n` - Next window
- `Ctrl-b p` - Previous window
- `Ctrl-b d` - Detach from session

### Zsh

- `Ctrl-R` - Search command history (with fzf)
- `Ctrl-T` - Search files (with fzf)
- `Alt-C` - Change directory (with fzf)

---

## Resources

- [Main README](../README.md)
- [Setup Guide](SETUP.md)
- [Nix Architecture](NIX_ARCHITECTURE.md)
- [Emergency Procedures](EMERGENCY_PROCEDURES.md)
- [Troubleshooting](TROUBLESHOOTING.md)
- [OpenCode Tmux Fix](OPENCODE_TMUX_FIX.md)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [Nix Package Search](https://search.nixos.org/packages)
