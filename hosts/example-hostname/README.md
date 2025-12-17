# Host-Specific Configuration

This directory contains configuration overrides for a specific host.

## Usage

Rename this directory to match your hostname:
```bash
mv example-hostname $(hostname)
```

## Files

- `host.sh` - Shell configuration sourced by .zshrc
- `files/` - Any files to copy to $HOME (overriding stow packages)

## Examples

### Different Git Email
```bash
mkdir -p files/.config/git
cat > files/.config/git/config.local << 'INNEREOF'
[user]
    email = work@company.com
INNEREOF
```

Then add to stow/git/.gitconfig:
```
[include]
    path = ~/.config/git/config.local
```

### Custom Aliases
Add to `host.sh`:
```bash
alias deploy-prod="ssh prod 'cd /app && ./deploy.sh'"
alias vpn-connect="sudo openvpn /etc/openvpn/work.conf"
```
