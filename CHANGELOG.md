# Changelog

All notable changes to this dotfiles repository will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Makefile for common operations (switch, update, validate, health, clean, check)
- Pre-commit hooks configuration for code quality
- CHANGELOG.md for tracking changes

### Fixed
- Configuration name mismatch in `update.sh` script (removed `-linux` suffix)
- Removed unused `username` parameter from `git.nix`
- Fixed hardcoded paths in documentation (QUICK_REFERENCE.md)
- Improved `hm` function to use `$DOTFILES` environment variable
- Enhanced `check_internet` function with fallback DNS servers
- Fixed sed compatibility issue in `setup-github-ssh.sh` for macOS
- Added confirmation prompt to `generate-project-mcp.js` with `--force` flag
- Added shellcheck directive to suppress known warning in `utils.sh`

### Improved
- Better error handling in health-check script (now uses shared utilities)
- Added comments explaining duplicate tool installation in neovim.nix
- Documented `--impure` flag requirement in default.nix
- Added session persistence note to SSH agent setup

### Security
- Documented SSH key passphrase considerations
- Added MCP server security implications documentation

---

## [Previous Versions]

### Key Features
- Cross-platform support (macOS/Linux)
- Nix flakes with Home Manager
- Modern CLI tools (eza, bat, ripgrep, fd, etc.)
- Neovim with LSP support
- Tmux configuration
- Zsh with Starship prompt
- Git with Delta
- Project templates with Devbox
- MCP server management for Claude Code/OpenCode
- SSH host configuration management
- Comprehensive setup scripts

### Philosophy
- Declarative configuration management
- Reproducible environments
- Minimal global tools, project-specific dependencies
- Privacy-aware (gitignored sensitive configs)
- Cross-platform compatibility