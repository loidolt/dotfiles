# Dotfiles

A centralized repository for managing personal workstation configuration files.

## Overview

This repository contains configuration files for:
- **OpenCode** - AI-powered code editor CLI
- **WezTerm** - GPU-accelerated terminal emulator
- **Neovim** - Modern text editor based on kickstart.nvim

## Repository Structure

```
dotfiles/
├── opencode/           # OpenCode configuration
│   ├── opencode.json   # Main config with MCP servers
│   ├── .gitignore      # Ignored files (node_modules, etc.)
│   └── README.md       # OpenCode-specific docs
├── wezterm/            # WezTerm configuration
│   ├── .wezterm.lua    # Main config file
│   └── README.md       # WezTerm-specific docs
├── neovim/             # Neovim configuration
│   ├── init.lua        # Main init file
│   ├── lua/            # Lua modules
│   │   ├── custom/     # Custom configurations
│   │   └── kickstart/  # Kickstart-based configs
│   └── README.md       # Neovim-specific docs
├── install.sh          # Installation script
├── uninstall.sh        # Uninstallation script
└── README.md           # This file
```

## Quick Start

### Installation

1. Clone this repository:
   ```bash
   git clone https://github.com/yourusername/dotfiles.git ~/dotfiles
   cd ~/dotfiles
   ```

2. Run the installation script:
   ```bash
   ./install.sh
   ```

The script will:
- Create symbolic links from this repository to the appropriate locations
- Backup any existing configurations with timestamps
- Set up all configurations automatically

### Uninstallation

To remove the symlinks (and optionally restore backups):
```bash
./uninstall.sh
```

## Manual Installation

If you prefer to install configurations manually:

### OpenCode
```bash
ln -s ~/dotfiles/opencode ~/.config/opencode
```

### WezTerm
```bash
ln -s ~/dotfiles/wezterm/.wezterm.lua ~/.wezterm.lua
```

### Neovim
```bash
ln -s ~/dotfiles/neovim ~/.config/nvim
```

## Configuration Details

### OpenCode
- MCP servers configured: context7, sequentialthinking, memory, playwright, github
- Theme: Catppuccin
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

## Adding New Configurations

To add a new application configuration:

1. Create a new directory for the application:
   ```bash
   mkdir application-name
   ```

2. Add the configuration files to that directory

3. Update `install.sh` to add a symlink section for the new config

4. Create a README.md in the directory documenting the configuration

5. Commit and push your changes

## Best Practices

- **Security**: Avoid committing sensitive data like API keys
  - Use environment variables when possible
  - Add sensitive files to `.gitignore`
  
- **Backups**: The install script automatically backs up existing configs

- **Testing**: Test on a fresh system or VM before relying on these configs

- **Documentation**: Keep README files updated when making changes

## Syncing Configurations

### From System to Repository

If you make changes to your live configs and want to sync them back:

```bash
# For OpenCode (if needed, usually auto-synced)
cp -r ~/.config/opencode/* ~/dotfiles/opencode/

# For WezTerm
cp ~/.wezterm.lua ~/dotfiles/wezterm/.wezterm.lua

# For Neovim (if you made changes to the base config)
cp ~/.config/nvim/init.lua ~/dotfiles/neovim/init.lua
```

Then commit and push the changes.

### From Repository to System

Your configurations are symlinked, so changes to the repository are immediately reflected in your system. Just pull the latest changes:

```bash
cd ~/dotfiles
git pull
```

## Troubleshooting

### Symlinks not working
- Ensure the install script has execute permissions: `chmod +x install.sh`
- Check that symlinks point to the correct location: `ls -la ~/.config/opencode`

### Neovim plugins not loading
- Run `:Lazy sync` in Neovim to install/update plugins
- Check `:checkhealth` for any issues

### WezTerm config not applied
- Restart WezTerm completely
- Check for syntax errors: `wezterm show-config`

## Contributing

This is a personal dotfiles repository, but feel free to fork it and adapt it to your needs!

## License

See the LICENSE file for details.