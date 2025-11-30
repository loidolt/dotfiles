# Package Management Guide

## Philosophy: Global vs Project-Specific

This guide outlines our approach to package management across Nix and Homebrew, following the principle: **Keep your global environment minimal, make projects self-contained.**

## Current State Analysis

### Homebrew Audit Results

Based on our audit of `brew list`, we have **40+ formula packages** and **9 cask applications**.

## Package Categories

### ✅ Global Tools (Managed by Nix)

These are core utilities you use across all projects, regardless of tech stack.

#### Already Configured in Nix
- `gh` - GitHub CLI
- `lazygit` - Git TUI
- `tmux` - Terminal multiplexer
- `neovim` - Text editor
- `wget` - File downloader
- `watch` - Command monitor
- `tree` - Directory visualizer
- `curl` - HTTP client
- `jq` - JSON processor
- Modern CLI tools: `ripgrep`, `fd`, `bat`, `fzf`, `eza`, `zoxide`

#### Recommended Additions to Nix
- `btop` - System monitor (better than htop)
- `mosh` - Mobile shell for unstable connections
- `p7zip` - 7-Zip archive utility
- `pandoc` - Universal document converter
- `lazydocker` - Docker TUI (complements lazygit)

### 🚫 Project-Specific Tools (Remove from Global)

These should be managed per-project using **devbox**:

#### Language Runtimes & Version Managers
- ❌ `go` - Use per-project version
- ❌ `deno` - Use per-project
- ❌ `node@18`, `node@22`, `nvm` - Use per-project (keep nodejs_20 global)
- ❌ `php` - Use per-project
- ❌ `ruby` - Use per-project
- ❌ `openjdk` - Use per-project
- ❌ `python@3.10`, `python@3.12` - Use per-project (keep one global)

#### Kubernetes & Infrastructure
- ❌ `kubernetes-cli` (kubectl)
- ❌ `k9s`
- ❌ `argocd`
- ❌ `grpcurl`
- ❌ `ansible`
- ❌ `ansible-lint`

#### Language-Specific Package Managers & Tools
- ❌ `pnpm` - Node package manager
- ❌ `cocoapods` - iOS dependencies
- ❌ `pipx` - Python app installer
- ❌ `mypy` - Python type checker
- ❌ `pytest` - Python testing
- ❌ `yamllint` - YAML linter

### 🔧 Specialized Tools (Keep in Homebrew)

Some tools are difficult to package in Nix or vendor-specific:

#### Microsoft SQL Server Tools
- `msodbcsql` / `msodbcsql17`
- `mssql-tools`

**Reason**: Vendor-specific, frequently updated, complex licensing

#### Specialized Utilities
- `wireshark` - Network protocol analyzer (complex GUI)
- `putty` - SSH/telnet tools
- `sshpass` - SSH password automation (security risk - consider removing)
- `wakeonlan` - Wake-on-LAN utility
- `cmatrix` - Terminal eye candy 😎

### 📦 GUI Applications (Keep as Homebrew Casks)

Casks are the best way to manage GUI applications on macOS:

- `docker` / `docker-desktop`
- `ghostty` (also managed in Nix for config)
- `warp`
- `flutter`
- `godot`
- `android-platform-tools`
- `nrfutil`
- `disk-inventory-x`

## Implementation Plan

### Step 1: Enhance Nix Global Packages

The following packages have been added to `home/packages.nix`:

```nix
# System monitoring and management
btop         # Better system monitor

# Network and remote access
mosh         # Mobile shell

# Archive utilities
p7zip        # 7-Zip support

# Document processing
pandoc       # Universal document converter

# Development tools
devbox       # Project-specific dev environments
lazydocker   # Docker TUI
```

Apply changes:
```bash
home-manager switch --flake ~/.config/home-manager
```

### Step 2: Use Devbox for Project Environments

We use **[devbox](https://www.jetify.com/devbox)** for project-specific environments. Devbox is a user-friendly wrapper around Nix that provides:

- Simple JSON configuration instead of complex Nix syntax
- Automatic shell integration
- Built-in scripts support
- Cross-platform compatibility
- Easy package search and management

#### Available Templates

Pre-configured templates are available in `project-templates/`:

1. **kubernetes/** - Kubernetes development (kubectl, helm, k9s, argocd)
2. **golang/** - Go development (go, gopls, golangci-lint, delve)
3. **python/** - Python development (python, poetry, ruff, mypy, pytest)
4. **nodejs/** - Node.js development (node, pnpm, typescript)
5. **infrastructure/** - Infrastructure as Code (ansible, terraform, packer)

#### Example: Kubernetes Template

**File**: `devbox.json`
```json
{
  "packages": [
    "kubectl@latest",
    "kubernetes-helm@latest",
    "k9s@latest",
    "argocd@latest",
    "grpcurl@latest"
  ],
  "shell": {
    "init_hook": [
      "echo '🚀 Kubernetes development environment loaded'",
      "kubectl version --client 2>/dev/null || echo 'kubectl: ready'"
    ],
    "scripts": {
      "check-cluster": ["kubectl cluster-info"],
      "dashboard": ["k9s"]
    }
  }
}
```

**Usage:**
```bash
# Enter the environment
devbox shell

# Run scripts
devbox run check-cluster
devbox run dashboard
```

See individual template READMEs for detailed usage instructions.

### Step 3: Clean Up Homebrew

A cleanup script has been created at `scripts/cleanup-brew.sh` to remove project-specific packages.

**Run the script:**
```bash
./scripts/cleanup-brew.sh
```

This will uninstall:
- Language runtimes (go, deno, node versions, php, ruby, python versions, openjdk)
- Kubernetes tools (kubectl, k9s, argocd, grpcurl)
- Infrastructure tools (ansible, ansible-lint)
- Language-specific tools (pnpm, cocoapods, pipx, mypy, pytest, yamllint)

### Step 4: Migration Workflow

For each existing project:

1. **Copy appropriate template** from `project-templates/`:
   ```bash
   # Example: Kubernetes project
   cp ~/Documents/GitHub/dotfiles/project-templates/kubernetes/devbox.json .
   ```

2. **Enter the environment:**
   ```bash
   devbox shell
   ```

3. **Test** that all tools are available:
   ```bash
   kubectl version --client
   helm version
   ```

4. **Add to `.gitignore`**:
   ```
   .devbox/
   devbox.lock
   ```

5. **Commit `devbox.json`** to version control:
   ```bash
   git add devbox.json
   git commit -m "Add devbox configuration for reproducible dev environment"
   ```

#### Quick Copy Commands

```bash
# Kubernetes project
cp ~/Documents/GitHub/dotfiles/project-templates/kubernetes/devbox.json .

# Go project
cp ~/Documents/GitHub/dotfiles/project-templates/golang/devbox.json .

# Python project
cp ~/Documents/GitHub/dotfiles/project-templates/python/devbox.json .

# Node.js project
cp ~/Documents/GitHub/dotfiles/project-templates/nodejs/devbox.json .

# Infrastructure project
cp ~/Documents/GitHub/dotfiles/project-templates/infrastructure/devbox.json .
```

## Benefits of This Approach

### ✅ Reproducibility
- Projects are self-contained
- New team members: `git clone` → `direnv allow` → done
- No "works on my machine" issues

### ✅ Version Control
- Different projects can use different tool versions
- No conflicts between project requirements
- Lock files ensure exact reproducibility

### ✅ Clean Global Environment
- Only essential tools installed globally
- No version pollution
- Faster system maintenance

### ✅ Documentation
- `flake.nix` documents exact dependencies
- No hidden requirements
- Infrastructure as code

## Maintenance

### Adding New Global Tools

Ask yourself:
1. **Do I use this across ALL projects?** → Add to Nix
2. **Is this project/language-specific?** → Add to project flake
3. **Is this a GUI app?** → Use Homebrew cask
4. **Is this vendor-specific/complex?** → Keep in Homebrew

### Updating Global Tools

```bash
# Update Nix packages
nix flake update ~/.config/home-manager
home-manager switch --flake ~/.config/home-manager

# Update Homebrew (for casks and specialized tools)
brew update && brew upgrade
```

### Updating Project Tools

```bash
# In project directory
devbox update          # Update all packages
devbox update kubectl  # Update specific package
```

## Quick Reference

### Check What's Installed Where

```bash
# Nix packages (global)
nix-env -q

# Homebrew formulas
brew list --formula

# Homebrew casks
brew list --cask

# Devbox packages in current project
devbox list

# Active commands in shell
which <command>
```

### Common Devbox Commands

```bash
# Initialize new project
devbox init

# Add package
devbox add kubectl

# Remove package
devbox remove kubectl

# Search for packages
devbox search python

# Enter development shell
devbox shell

# Run scripts
devbox run <script-name>

# Update packages
devbox update

# Show package info
devbox info kubectl
```

### Troubleshooting

#### "Command not found" in project

```bash
devbox shell          # Enter the shell
devbox install        # Install packages
```

#### Verify devbox configuration

```bash
devbox info           # Show environment info
devbox list           # List installed packages
```

#### Homebrew conflicts

```bash
brew doctor           # Check for issues
brew cleanup          # Remove old versions
```

#### Reset devbox environment

```bash
rm -rf .devbox        # Remove cached environment
devbox shell          # Rebuild from scratch
```

## Future Enhancements

- [ ] Create script to bootstrap new projects from templates
- [ ] Add pre-commit hooks to validate devbox.json
- [ ] Create custom devbox plugins for common workflows
- [ ] Document common package names (Homebrew vs Nix)
- [ ] Add cloud-specific templates (AWS, GCP, Azure)

## Resources

- [Devbox Documentation](https://www.jetify.com/devbox/docs/)
- [Devbox Examples](https://www.jetify.com/devbox/docs/examples/)
- [Nix Package Search](https://search.nixos.org/packages)
- [Home Manager Options](https://nix-community.github.io/home-manager/options.html)
- [Project Templates](../project-templates/)
