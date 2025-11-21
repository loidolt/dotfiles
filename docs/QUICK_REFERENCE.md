# Quick Reference Guide

## OpenCode Theme Not Working in Tmux

**Quick Fix:**
```bash
# Kill and restart tmux
tmux kill-server
tmux
```

**Why?** Tmux needs 24-bit truecolor support for OpenCode themes. The fix has been applied to your `.tmux.conf`.

**Details:** See [OPENCODE_TMUX_FIX.md](OPENCODE_TMUX_FIX.md)

---

## Common Commands

### Bootstrap
```bash
./bootstrap.sh              # Interactive setup
./bootstrap.sh --full       # Install everything
./bootstrap.sh --minimal    # Core packages only
./bootstrap.sh --dry-run    # Preview changes
```

### Dotfiles
```bash
./install.sh                # Install dotfiles
./uninstall.sh              # Remove symlinks
```

### Validation
```bash
./scripts/validate.sh       # Check installation
```

### Ansible
```bash
cd ansible
ansible-playbook setup.yml              # Run all
ansible-playbook setup.yml --tags packages   # Packages only
ansible-playbook setup.yml --check --diff    # Dry run
```

### Tmux
```bash
tmux source ~/.tmux.conf    # Reload config
tmux kill-server            # Restart tmux server
tmux new -s myname          # New named session
tmux attach -t myname       # Attach to session
```

### Environment
```bash
source ~/.dotfiles_env      # Load environment variables
echo $OPENCODE_API_KEY      # Check API key
```

---

## File Locations

### Configurations
- OpenCode: `~/.config/opencode/` → `~/dotfiles/opencode/`
- WezTerm: `~/.config/wezterm/` → `~/dotfiles/wezterm/`
- Neovim: `~/.config/nvim/` → `~/dotfiles/neovim/`
- Tmux: `~/.tmux.conf` → `~/dotfiles/tmux/.tmux.conf`

### Environment
- `~/.dotfiles_env` - Environment variables
- `~/.zshrc` - Shell configuration

### Ansible
- `~/dotfiles/ansible/group_vars/all.yml` - Package lists
- `~/dotfiles/ansible/setup.yml` - Main playbook

---

## Troubleshooting

### Check Installation
```bash
./scripts/validate.sh
```

### Fix Tmux Colors
```bash
# 1. Verify truecolor config is loaded
tmux show-options -g -s | grep terminal

# 2. Restart tmux completely
tmux kill-server && tmux

# 3. Test colors
echo $TERM        # Should be: tmux-256color
echo $COLORTERM   # Should be: truecolor
```

### Check Symlinks
```bash
ls -la ~/.config/opencode
ls -la ~/.config/wezterm
ls -la ~/.config/nvim
ls -la ~/.tmux.conf
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
# Test color gradient
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
which git node bun docker opencode nvim
brew list            # macOS
apt list --installed # Linux
```

### Check Environment Variables
```bash
env | grep -E "(API|KEY|PATH)"
```

---

## Quick Edits

### Edit Dotfiles
```bash
# Edit in VS Code
code ~/dotfiles

# Edit specific configs
nvim ~/dotfiles/opencode/opencode.json
nvim ~/dotfiles/tmux/.tmux.conf
nvim ~/.dotfiles_env
```

### Update Package Lists
```bash
nvim ~/dotfiles/ansible/group_vars/all.yml
cd ~/dotfiles/ansible
ansible-playbook setup.yml
```

---

## Git Workflow

### Update Dotfiles
```bash
cd ~/dotfiles
git pull
./install.sh  # Re-symlink if needed
```

### Commit Changes
```bash
cd ~/dotfiles
git add .
git commit -m "Update configuration"
git push
```

---

## Resources

- [Main README](../README.md)
- [Setup Guide](SETUP.md)
- [OpenCode Tmux Fix](OPENCODE_TMUX_FIX.md)
- [OpenCode Docs](https://opencode.ai/docs)
- [Tmux Guide](https://github.com/tmux/tmux/wiki)
