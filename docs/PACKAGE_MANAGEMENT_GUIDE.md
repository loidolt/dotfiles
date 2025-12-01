# Package Management Guide

## Philosophy: Global vs Project-Specific

This guide outlines the approach to package management with Nix, following the principle: **Keep your global environment minimal, make projects self-contained.**

## Package Categories

### ✅ Global Tools (Managed by Nix)

These are core utilities you use across all projects, regardless of tech stack. These are configured in `home/packages.nix`:

- `gh` - GitHub CLI
- `lazygit` - Git TUI
- `tmux` - Terminal multiplexer
- `neovim` - Text editor
- `wget`, `curl` - File/HTTP downloaders
- `tree`, `btop`, `btop` - System utilities
- `jq`, `yq` - JSON/YAML processors
- Modern CLI tools: `ripgrep`, `fd`, `bat`, `fzf`, `eza`, `zoxide`, `delta`
- Development tools: `git`, `delta`, `lazygit`

### 🚫 Project-Specific Tools (Use Devbox or Nix Shell)

These should be managed per-project using **devbox** or project-specific `shell.nix` files:

#### Language Runtimes & Version Managers
- Different versions of Go, Python, Node.js, Ruby, etc.
- Language-specific package managers (pnpm, poetry, etc.)
- Build tools specific to a language/framework

#### Project-Specific Infrastructure Tools
- Kubernetes tools (kubectl, k9s, helm)
- Cloud provider CLIs (aws-cli, gcloud, azure-cli)
- Infrastructure as Code tools (terraform, ansible, pulumi)
- Container orchestration tools

#### Language-Specific Development Tools
- Linters, formatters, type checkers
- Testing frameworks
- Language servers (if not needed globally)

### 📦 GUI Applications (macOS)

On macOS, GUI applications can be managed with:
- **Homebrew Casks** - Traditional method, good for proprietary apps
- **Nix Darwin** - Declarative management (advanced setup)

Common GUI applications:
- Docker Desktop
- Terminal emulators (Ghostty, Warp, etc.)
- Browsers
- Development tools (VS Code, etc.)

## Adding Global Packages

### Step 1: Edit Package List

Edit `home/packages.nix`:

```nix
home.packages = with pkgs; [
  # Add your new package here
  your-package-name
];
```

### Step 2: Rebuild

```bash
home-manager switch --flake ~/Documents/GitHub/dotfiles#chrisloidolt
```

### Step 3: Verify

```bash
which your-package-name
# Should show /nix/store/... path
```

## Project-Specific Environments

### Option 1: Devbox (Recommended for Most Projects)

**[Devbox](https://www.jetify.com/devbox)** is a user-friendly wrapper around Nix:

- Simple JSON configuration
- Automatic shell integration
- Built-in scripts support
- Easy to use and share

### Option 2: Nix Shell (Advanced)

For more control, use `shell.nix` or `flake.nix` directly:

```nix
# shell.nix
{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  packages = with pkgs; [
    nodejs_20
    typescript
    # ... other packages
  ];
}
```

Then run: `nix-shell`

#### Devbox Example

Create `devbox.json` in your project:

```json
{
  "packages": [
    "kubectl@latest",
    "kubernetes-helm@latest",
    "k9s@latest"
  ],
  "shell": {
    "init_hook": [
      "echo 'Dev environment loaded'"
    ]
  }
}
```

Then:
```bash
devbox shell  # Enter environment
# All tools available here
```

## Using Direnv for Automatic Environment Loading

With direnv configured in your dotfiles, project environments can load automatically.

### Setup with Devbox

```bash
cd your-project
devbox init
# Edit devbox.json as needed
echo "use devbox" > .envrc
direnv allow
```

Now the environment loads automatically when you `cd` into the directory!

### Setup with Nix Shell

```bash
cd your-project
# Create shell.nix
echo "use nix" > .envrc
direnv allow
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
cd ~/Documents/GitHub/dotfiles
nix flake update
home-manager switch --flake .#chrisloidolt
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
# Nix packages (from Home Manager)
home-manager packages

# Active commands in shell
which <command>

# Devbox packages in current project (if using devbox)
devbox list
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



#### Reset devbox environment

```bash
rm -rf .devbox        # Remove cached environment
devbox shell          # Rebuild from scratch
```



## Resources

- [Nix Package Search](https://search.nixos.org/packages)
- [Home Manager Options](https://nix-community.github.io/home-manager/options.html)
- [Devbox Documentation](https://www.jetify.com/devbox/docs/)
- [Nix Pills](https://nixos.org/guides/nix-pills/) - Learn Nix in depth
