# Dotfiles Project

Personal dotfiles managed with GNU Stow for macOS and Linux.

## Project Structure

```
dotfiles/
├── stow/                    # Stow packages (symlinked to ~)
│   ├── zsh/                 # Shell configuration
│   ├── git/                 # Git configuration
│   ├── tmux/                # Tmux configuration (cmux-aware)
│   ├── claude/              # Claude Code agents, skills, hooks, MCP
│   ├── codex/ gemini/       # Other AI CLIs (runtime state gitignored)
│   └── ...                  # ghostty, starship, fzf, navi, ssh, direnv
├── scripts/                 # Automation scripts
│   └── lib/utils.sh         # Shared bash utilities
├── packages/                # Package lists per OS
├── Makefile                 # Main entry point
├── install.sh               # Full installation
├── stow-all.sh              # Restow all packages
└── uninstall.sh             # Remove all symlinks
```

## Common Commands

```bash
make install      # Full setup (packages + stow)
make update       # Pull changes and restow
make stow-all     # Restow all packages
make health-check # Diagnose issues
make setup-git    # Configure git credentials
make ssh          # Setup GitHub SSH key
```

## Stow Package Pattern

Each package in `stow/` mirrors home directory structure:
- `stow/zsh/.zshrc` → `~/.zshrc`
- `stow/git/.gitconfig` → `~/.gitconfig`
- `stow/claude/.claude/` → `~/.claude/`

**Adding a new package:**
1. Create directory: `stow/<package>/`
2. Add files with home-relative paths
3. Run `stow -v -t "$HOME" <package>`

## Script Conventions

Scripts use shared utilities from `scripts/lib/utils.sh`:
- `info`, `success`, `warning`, `error` - Colored output
- `is_macos`, `is_linux` - OS detection
- `command_exists` - Check for installed commands
- `run_stow` - Safe stow wrapper

## Working in This Repo

- **Config changes**: Edit in `stow/<package>/`, then `make stow-all`
- **New tools**: Add to `packages/` lists, update install scripts
- **Scripts**: Follow existing patterns in `scripts/`
- **Testing**: Run `make health-check` after changes
- **Linting**: `pre-commit run --all-files` (shellcheck, JSON/YAML/TOML checks)
- **Git flow**: Feature branch + PR; pre-commit blocks commits to `main`

## Claude Code Integration

Custom agents in `stow/claude/.claude/agents/` (`<name>.md` with `name`/`description`/`model` frontmatter):
- Use `haiku` model for quick lookups
- Use `sonnet` for code review and testing
- Use `opus` for architecture and refactoring

Custom skills in `stow/claude/.claude/skills/<name>/SKILL.md` (frontmatter required, flat `.md` files are ignored):
- `/stow-manage` - GNU Stow operations
- `/git-sync` - Git sync workflow
- `/health-check` - Project diagnostics
- `/package-update` - Update packages
- `/mcp-sync` - MCP server management

Hooks in `stow/claude/.claude/hooks/`:
- `agent-notify.sh` - cmux notifications (OSC 777, tmux passthrough) for Claude Code `Stop`/`Notification` and Codex `notify`. Registered in the untracked `~/.claude/settings.json`.

Vendor skills (Cloudflare etc.) and `skills/synced/` are gitignored; don't commit them.

## Platform Notes

- **macOS**: Uses Homebrew, zsh default
- **Linux**: Supports apt/dnf/pacman, may need `chsh` for zsh
- **Both**: Most configs are cross-platform
