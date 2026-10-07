# Changelog

All notable changes to this dotfiles repository will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- cmux agent notifications (`stow/claude/.claude/hooks/agent-notify.sh`) for Claude Code and Codex, working over ssh and inside tmux
- tmux: passthrough for background windows, OSC 52 clipboard, extended keys, bell forwarding, TPM auto-bootstrap
- health-check: TPM, notify hook and `.zshenv` checks

### Fixed
- Claude Code agents and skills now load (added YAML frontmatter, skills moved to `<name>/SKILL.md`)
- `.pre-commit-config.yaml` was invalid; now uses pre-commit-hooks + shellcheck
- Shellcheck warnings across scripts
- npm globals prefer nvm's node

### Changed
- Codex/Gemini runtime state and vendor skills are gitignored (Codex dir uses a whitelist)
- Removed stale OpenCode and Neovim references from docs

## Nix → Stow migration

### Changed
- **BREAKING**: Fully migrated from Nix to GNU Stow + package managers
- Replaced update.sh with package manager-based update script
- Updated health-check.sh to check Stow setup instead of Nix
- Removed all Nix references from CONTRIBUTING.md
- Updated .zshrc to remove Nix daemon sourcing

### Added
- .gitconfig.example as a template for personal git configuration
- Enhanced .gitignore for better security (added .env, *.key, *.pem, etc.)
- SSH key generation now prompts for passphrase (security improvement)
- Better update script supporting Homebrew, apt, dnf, and pacman

### Fixed
- initial-setup.sh now references correct installation script
- Removed personal information from .gitconfig (now uses placeholders)
- Fixed script references throughout documentation
- Security: SSH keys now prompt for passphrase instead of generating without one

### Removed
- All Nix-related configuration and references
- Nix flake files
- home-manager references

---

## [Previous Versions]

### Key Features (Before Nix Removal)
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
