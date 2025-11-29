# Legacy Ansible Setup

> **⚠️ DEPRECATED:** This directory contains the old Ansible-based setup system.
> 
> **Use Nix instead!** See the main [README.md](../README.md) for current setup.

## What's Here

This directory contains the original Ansible-based dotfiles management system that has been **replaced by Nix and Home Manager**.

### Files Archived

- **ansible/** - Ansible playbooks and roles for package installation
- **bootstrap.sh** - Old one-command setup script
- **install.sh** - Old dotfiles symlink script  
- **uninstall.sh** - Old symlink removal script

## Why Did We Switch to Nix?

The Ansible approach had several limitations:

1. **Not Truly Declarative** - Ansible is imperative (runs commands), not declarative
2. **No Rollback** - Can't easily undo changes
3. **Platform-Specific** - Different playbooks for macOS/Linux
4. **Stateful** - System state can drift from config
5. **Manual Management** - Package updates require manual intervention

## Nix Advantages

1. ✅ **Declarative** - Describe what you want, not how to get it
2. ✅ **Reproducible** - Same config = same result, always
3. ✅ **Atomic** - All-or-nothing updates
4. ✅ **Rollback** - Can revert to any previous generation
5. ✅ **Cross-Platform** - Same config works on macOS, NixOS, WSL2
6. ✅ **Immutable** - Packages can't be accidentally modified

## Migration Timeline

- **Created**: November 2024
- **Archived**: November 29, 2025
- **Replaced By**: Nix Flakes + Home Manager (see `flake.nix` and `home/`)

## Can I Still Use This?

**Not recommended.** The Ansible setup is no longer maintained and may have:
- Outdated package versions
- Broken playbooks
- Incompatibilities with current system

**Instead:**
1. Follow the main [README.md](../README.md) for Nix setup
2. Or see [MIGRATION_README.md](../MIGRATION_README.md) for migration guide

## Safe to Delete?

**Keep for reference until:** 6 months after migration (May 2025)

After that, this directory can be safely deleted if the Nix setup is working well.

---

**Last Updated**: November 29, 2025  
**Archived By**: NixOS Migration (Phase 2 Complete)
