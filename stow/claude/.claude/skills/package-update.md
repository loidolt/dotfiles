# Package Update

Update project and system packages.

---

/package-update [scope]

---

Update installed packages using the appropriate package manager.

## Scope Options

- `project` - Update project dependencies (default)
- `system` - Update system packages (brew/apt)
- `all` - Update both project and system
- `check` - Show outdated packages without updating

## Project Package Managers

Automatically detects and uses:
- **npm/yarn/pnpm**: `package.json`
- **pip/poetry**: `requirements.txt`, `pyproject.toml`
- **cargo**: `Cargo.toml`
- **go**: `go.mod`
- **composer**: `composer.json`

## System Package Managers

- **Homebrew** (macOS/Linux): `brew update && brew upgrade`
- **APT** (Debian/Ubuntu): `apt update && apt upgrade`
- **DNF** (Fedora): `dnf upgrade`

## Update Commands

### Project Dependencies
```bash
# npm
npm update && npm audit fix

# yarn
yarn upgrade

# pip
pip install --upgrade -r requirements.txt

# cargo
cargo update
```

### System Packages
```bash
# Homebrew
brew update && brew upgrade && brew cleanup

# APT
sudo apt update && sudo apt upgrade -y
```

## Safety Features

- Show what will be updated before proceeding
- Create lockfile backup before major updates
- Report any failures clearly
- Suggest manual intervention for breaking changes

## Usage

```
/package-update           # Update project deps
/package-update system    # Update system packages
/package-update check     # Just show outdated
```
