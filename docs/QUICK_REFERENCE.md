# Quick Reference

## Common Commands

### Initial Setup
```bash
# Clone and setup everything
git clone https://github.com/yourusername/dotfiles.git ~/dotfiles
cd ~/dotfiles
./bootstrap.sh

# Full setup (non-interactive)
./bootstrap.sh --full

# Minimal setup
./bootstrap.sh --minimal

# Just dotfiles
./bootstrap.sh --dotfiles-only

# Dry run
./bootstrap.sh --dry-run
```

### Update Existing System
```bash
# Update dotfiles
cd ~/dotfiles
git pull

# Update packages
cd ~/dotfiles/ansible
ansible-playbook setup.yml --tags packages

# Update everything
cd ~/dotfiles
./bootstrap.sh --full
```

### Validation
```bash
# Check installation
./scripts/validate.sh

# Check what's installed
which git node docker ansible
```

### Environment
```bash
# Edit environment
nvim ~/.dotfiles_env

# Reload environment
source ~/.dotfiles_env

# Setup environment (creates file)
./scripts/env-setup.sh
```

### SSH
```bash
# Setup SSH keys
./scripts/ssh-setup.sh

# Test GitHub connection
ssh -T git@github.com
```

### Ansible Tasks
```bash
cd ~/dotfiles/ansible

# Run specific tags
ansible-playbook setup.yml --tags packages
ansible-playbook setup.yml --tags languages
ansible-playbook setup.yml --tags docker
ansible-playbook setup.yml --tags shell
ansible-playbook setup.yml --tags applications

# Dry run
ansible-playbook setup.yml --check --diff

# Verbose
ansible-playbook setup.yml -v
```

### Dotfiles Management
```bash
# Link dotfiles
./install.sh

# Unlink dotfiles
./uninstall.sh

# Check symlinks
ls -la ~/.config/opencode
ls -la ~/.config/wezterm
ls -la ~/.config/nvim
```

## File Locations

### Configuration Files
- **Dotfiles repo**: `~/dotfiles/`
- **Symlinked configs**: `~/.config/`
- **Environment vars**: `~/.dotfiles_env`
- **Shell config**: `~/.zshrc` or `~/.bashrc`

### Ansible
- **Playbook**: `~/dotfiles/ansible/setup.yml`
- **Package lists**: `~/dotfiles/ansible/group_vars/all.yml`
- **Roles**: `~/dotfiles/ansible/roles/`

### Scripts
- **Bootstrap**: `~/dotfiles/bootstrap.sh`
- **Environment**: `~/dotfiles/scripts/env-setup.sh`
- **SSH**: `~/dotfiles/scripts/ssh-setup.sh`
- **Validation**: `~/dotfiles/scripts/validate.sh`

## Customization

### Add Packages
Edit `ansible/group_vars/all.yml`:
```yaml
packages:
  core:
    - your-package
```

Run:
```bash
cd ansible
ansible-playbook setup.yml --tags packages
```

### Change Node Version
Edit `ansible/group_vars/all.yml`:
```yaml
languages:
  node_version: "18"  # Change to desired version
```

Run:
```bash
cd ansible
ansible-playbook setup.yml --tags languages
```

### Add GUI Apps (macOS)
Edit `ansible/group_vars/all.yml`:
```yaml
applications:
  apps:
    - your-app
```

Run:
```bash
cd ansible
ansible-playbook setup.yml --tags applications
```

## Environment Variables

### Required
```bash
export REF_API_KEY="your-key"
export CONTEXT7_API_KEY="your-key"
```

### Optional
```bash
export EDITOR="nvim"
export FZF_DEFAULT_COMMAND='fd --type f'
```

### Setup
1. Edit `~/.dotfiles_env`
2. Add to `~/.zshrc`: `source ~/.dotfiles_env`
3. Reload: `source ~/.zshrc`

## Troubleshooting

### Command Not Found
```bash
# Reload environment
source ~/.dotfiles_env
source ~/.zshrc

# Check PATH
echo $PATH

# Restart terminal
```

### Ansible Errors
```bash
# Install/update Ansible
brew install ansible  # macOS
sudo apt install ansible  # Linux

# Check Ansible
ansible --version
```

### Docker Issues
```bash
# macOS: Start Docker Desktop
open -a Docker

# Linux: Add user to group
sudo usermod -aG docker $USER
newgrp docker
```

### Symlink Issues
```bash
# Remove and recreate
./uninstall.sh
./install.sh

# Check if symlink exists
ls -la ~/.config/opencode
```

## Package Managers

### Homebrew (macOS)
```bash
# Update
brew update

# Upgrade packages
brew upgrade

# Search
brew search package-name

# Install
brew install package-name
```

### mise (Version Manager)
```bash
# Install language
mise use -g node@20

# List installed
mise list

# Update mise
mise self-update
```

### Bun
```bash
# Update Bun
bun upgrade

# Install package globally
bun add -g package-name
```

## Git Workflow

### Update Dotfiles
```bash
cd ~/dotfiles
git status
git add .
git commit -m "Update configs"
git push
```

### Pull Changes
```bash
cd ~/dotfiles
git pull
# Changes apply immediately (symlinks!)
```

### New Machine
```bash
git clone git@github.com:yourusername/dotfiles.git ~/dotfiles
cd ~/dotfiles
./bootstrap.sh
```

## Useful Aliases

Add to `~/.zshrc`:
```bash
# Dotfiles shortcuts
alias dotfiles='cd ~/dotfiles'
alias dots='cd ~/dotfiles'
alias dotsync='cd ~/dotfiles && git pull'
alias dotupdate='cd ~/dotfiles/ansible && ansible-playbook setup.yml'

# Quick edit
alias editdots='code ~/dotfiles'
alias editenv='nvim ~/.dotfiles_env'
alias editzsh='nvim ~/.zshrc'

# Validation
alias checksetup='~/dotfiles/scripts/validate.sh'
```

## Next Steps After Setup

1. ✅ Restart terminal
2. ✅ Edit `~/.dotfiles_env` with real API keys
3. ✅ Run `./scripts/validate.sh`
4. ✅ Setup SSH: `./scripts/ssh-setup.sh`
5. ✅ Clone work repositories
6. ✅ Sign into applications (Chrome, VS Code, etc.)
7. ✅ Configure system preferences
8. ✅ Install any additional tools specific to your workflow

## Resources

- Main README: `~/dotfiles/README.md`
- Setup Guide: `~/dotfiles/docs/SETUP.md`
- Package Config: `~/dotfiles/ansible/group_vars/all.yml`
- Environment: `~/.dotfiles_env`
