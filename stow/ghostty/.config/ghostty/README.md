# Ghostty Configuration

This directory contains the Ghostty terminal emulator configuration.

## Features

- **Theme**: Catppuccin Mocha
- **Font**: JetBrains Mono (default bundled font)
- **Shell Integration**: Automatic detection
- **Customizable**: Easy-to-modify configuration file

## Installation

The configuration file should be symlinked to:
- Linux/macOS (XDG): `~/.config/ghostty/config`
- macOS (native): `~/Library/Application Support/com.mitchellh.ghostty/config`

## Configuration Structure

```
ghostty/
├── config          # Main configuration file
└── README.md       # This file
```

## Customization

The `config` file uses a simple `key = value` syntax. See the [Ghostty documentation](https://ghostty.org/docs/config) for all available options.

### Theme

Ghostty ships with hundreds of built-in themes. Current theme is Catppuccin Mocha.

To list all available themes:
```bash
ghostty +list-themes
```

To change themes, update the `theme` line in the config file:
```ini
theme = Catppuccin Mocha
```

### Reloading Configuration

Press `Ctrl+Shift+,` (Linux) or `Cmd+Shift+,` (macOS) to reload the configuration without restarting Ghostty.

## Documentation

- [Official Docs](https://ghostty.org/docs)
- [Configuration Reference](https://ghostty.org/docs/config/reference)
- [Theme Documentation](https://ghostty.org/docs/features/theme)
- [Keybindings](https://ghostty.org/docs/config/keybinds)

## Key Bindings

| Action | Linux | macOS |
|--------|-------|-------|
| New Tab | `Ctrl+Shift+T` | `Cmd+Shift+T` |
| Close Tab/Split | `Ctrl+Shift+W` | `Cmd+Shift+W` |
| Split Right | `Ctrl+Shift+D` | `Cmd+Shift+D` |
| Split Down | `Ctrl+Shift+Shift+D` | `Cmd+Shift+Shift+D` |
| Next Tab | `Ctrl+Tab` | `Cmd+Tab` |
| Previous Tab | `Ctrl+Shift+Tab` | `Cmd+Shift+Tab` |
| Zoom In | `Ctrl+=` | `Cmd+=` |
| Zoom Out | `Ctrl+-` | `Cmd+-` |
| Reset Zoom | `Ctrl+0` | `Cmd+0` |
| Reload Config | `Ctrl+Shift+,` | `Cmd+Shift+,` |
