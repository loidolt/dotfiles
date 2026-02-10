# Stow Management

Manage GNU Stow packages for dotfiles or any stow-managed directory.

---

/stow-manage [action] [package]

---

Manage symlinks using GNU Stow. Works with any stow package directory.

## Actions

- `list` - List all stow packages in current directory
- `status` - Check symlink status for all packages
- `install <package>` - Stow a specific package
- `remove <package>` - Unstow a specific package
- `restow <package>` - Restow (reinstall) a package
- `dry-run <package>` - Preview what would happen

## Usage Examples

```
/stow-manage list
/stow-manage status
/stow-manage install zsh
/stow-manage dry-run vim
```

## Implementation

1. Detect stow directory (current dir or `stow/` subdirectory)
2. Determine target directory (default: `$HOME`)
3. Execute the appropriate stow command with verbose output
4. Report results clearly

## Stow Commands Reference

```bash
# List packages
ls -d */

# Stow (install)
stow -v -t "$HOME" <package>

# Unstow (remove)
stow -v -D -t "$HOME" <package>

# Restow (reinstall)
stow -v -R -t "$HOME" <package>

# Dry run (preview)
stow -v -n -t "$HOME" <package>
```

## Error Handling

- Check if stow is installed
- Verify package directory exists
- Report conflicts clearly
- Suggest resolutions for common issues (existing files, broken links)
