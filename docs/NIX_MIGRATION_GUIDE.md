# NixOS Migration Guide - Detailed Instructions

**Companion Documents:**
- `MIGRATION_LOG.md` - Track your progress
- `MIGRATION_CHECKLIST.md` - Phase-by-phase checklist
- This document - Detailed commands and explanations

**How to Use This Guide:**
1. Work through one phase at a time
2. Use MIGRATION_CHECKLIST.md to track tasks
3. Document progress in MIGRATION_LOG.md
4. Refer to this guide for detailed commands

---

## Table of Contents

- [Phase 0: Preparation & Backup](#phase-0-preparation--backup)
- [Phase 1: Foundation](#phase-1-foundation)
- [Phase 2: Core Configuration](#phase-2-core-configuration)
- [Phase 3: NixOS VM Testing](#phase-3-nixos-vm-testing)
- [Phase 4: NixOS Production](#phase-4-nixos-production)
- [Phase 5: WSL2 Setup](#phase-5-wsl2-setup)
- [Phase 6: Validation & Cleanup](#phase-6-validation--cleanup)
- [Phase 7: Documentation & Polish](#phase-7-documentation--polish)

---

## Phase 0: Preparation & Backup

### Step-by-Step Instructions

#### 0.1: Backup Current System

```bash
# Navigate to dotfiles
cd ~/dotfiles

# Create and push backup branch
git checkout -b ansible-backup
git push -u origin ansible-backup

# Tag current state
git tag -a pre-nix-migration -m "System state before Nix migration"
git push --tags

# Export current packages (for reference)
# macOS:
brew list > ~/Desktop/brew-packages-backup.txt
brew list --cask > ~/Desktop/brew-casks-backup.txt

# Linux:
dpkg --get-selections > ~/Desktop/apt-packages-backup.txt
```

**Verify backup:**
```bash
# Check GitHub for branches
git branch -r | grep ansible-backup

# Check tags
git tag | grep pre-nix-migration
```

#### 0.2: Create Migration Tracking

```bash
# Create new branch for migration
git checkout -b nix-migration

# Migration files should already exist from previous session
# If not, create them:
# touch MIGRATION_LOG.md MIGRATION_CHECKLIST.md

# Edit MIGRATION_LOG.md and fill in:
# - Start date
# - Your username
# - Current machine info
```

#### 0.3: Install Nix on macOS

```bash
# Install Nix with daemon (multi-user)
sh <(curl -L https://nixos.org/nix/install) --daemon

# The installer will:
# 1. Download Nix
# 2. Create /nix directory
# 3. Create build users
# 4. Set up daemon service
# 5. Modify shell profile

# RESTART YOUR TERMINAL after installation
```

**Verify installation:**
```bash
# Check Nix version (should be >= 2.18)
nix --version

# Check Nix environment
nix-env --version

# Should see something like:
# nix (Nix) 2.18.x
```

**Enable Flakes:**
```bash
# Create Nix config directory
mkdir -p ~/.config/nix

# Enable experimental features
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf

# RESTART TERMINAL AGAIN
```

#### 0.4: Test Nix Functionality

```bash
# Test 1: Flake commands work
nix flake show github:nix-community/home-manager
# Should display home-manager flake outputs

# Test 2: Temporary shell
nix shell nixpkgs#hello --command hello
# Should print "Hello, world!"

# Test 3: Build a package
nix build nixpkgs#hello
# Should create a "result" symlink

# Clean up test
rm result

# If all three work, Nix is ready!
```

**Update MIGRATION_LOG.md:**
```markdown
### Phase 0: Preparation ✅
- [x] Backup current system
- [x] Create migration branch
- [x] Install Nix on macOS
- [x] Test Nix installation
**Completion Date:** 2024-XX-XX
**Notes:** Nix 2.18.x installed. Flakes enabled. All tests passed.
```

---

## Phase 1: Foundation

### Step-by-Step Instructions

#### 1.1: Create Directory Structure

```bash
cd ~/dotfiles

# Create all directories at once
mkdir -p hosts/{nixos-desktop,darwin,wsl} \
         home/programs \
         configs \
         modules \
         overlays

# Verify structure
tree -L 2 -d
# Or if tree not installed:
find . -type d -maxdepth 2 | sort
```

Expected structure:
```
dotfiles/
├── hosts/
│   ├── nixos-desktop/
│   ├── darwin/
│   └── wsl/
├── home/
│   └── programs/
├── configs/
├── modules/
└── overlays/
```

#### 1.2: Move Existing Configs

```bash
# Copy (don't move yet) existing configs to new location
cp -r neovim configs/
cp -r opencode configs/
cp -r ghostty configs/
cp -r tmux configs/

# Verify copies
ls -la configs/
# Should see: neovim, opencode, ghostty, tmux directories

# DO NOT delete originals yet!
```

#### 1.3: Create Minimal flake.nix

Create `flake.nix` in the root of dotfiles:

```nix
{
  description = "Cross-platform NixOS/macOS/WSL dotfiles";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, nix-darwin, nixos-wsl, ... }@inputs:
    let
      username = "chris";  # ⚠️ CHANGE THIS TO YOUR USERNAME
    in
    {
      # Home Manager standalone (for testing)
      homeConfigurations = {
        "${username}" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          extraSpecialArgs = { inherit inputs username; };
          modules = [ ./home ];
        };
      };
      
      # We'll add NixOS and Darwin configurations later
    };
}
```

**Important:** Replace "chris" with your actual username!

**Test the flake:**
```bash
# Check syntax
nix flake show

# Check metadata
nix flake metadata

# If both work, flake is valid
```

#### 1.4: Create Home Manager Minimal Config

Create `home/default.nix`:

```nix
{ config, pkgs, lib, username, ... }:

{
  home = {
    username = username;
    homeDirectory = 
      if pkgs.stdenv.isDarwin 
      then "/Users/${username}" 
      else "/home/${username}";
    
    stateVersion = "24.05";
  };

  # Let Home Manager manage itself
  programs.home-manager.enable = true;
}
```

#### 1.5: Test Build

```bash
# Try to build (won't activate, just build)
nix build .#homeConfigurations.YOUR_USERNAME.activationPackage

# If successful, you'll see a "result" symlink
ls -la result

# Check what's inside
ls -la result/

# Clean up
rm result
```

**If you get errors:**
- Check flake.nix syntax
- Verify username matches in both files
- Run `nix flake check` for detailed errors

**Update MIGRATION_LOG.md and commit:**
```bash
git add flake.nix flake.lock home/
git commit -m "Phase 1: Create basic Nix structure"
git tag -a phase-1-complete -m "Nix structure created and builds"
git push origin nix-migration --tags
```

---

## Phase 2: Core Configuration

This is the longest phase. Take your time and test after each step.

### 2.1: Create packages.nix

Create `home/packages.nix`:

```nix
{ pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    # Core utilities
    coreutils
    curl
    wget
    unzip
    tree
    htop
    jq
    yq

    # Modern CLI tools (from your Ansible config)
    ripgrep      # Better grep (rg)
    fd           # Better find
    bat          # Better cat
    eza          # Better ls (was exa)
    zoxide       # Smart cd (z)
    delta        # Better git diff
    duf          # Better df
    dust         # Better du
    procs        # Better ps
    bottom       # Better top (btm)
    
    # Development tools
    git
    gh           # GitHub CLI
    lazygit      # Git TUI
    
    # Languages (from your Ansible group_vars/all.yml)
    nodejs_20    # Node.js LTS
    bun          # Fast JavaScript runtime
    
    # Node global packages
    nodePackages.typescript
    nodePackages.prettier
    nodePackages.eslint
    
    # Misc
    tldr         # Simplified man pages
    httpie       # Better curl for APIs
    
  ] ++ lib.optionals pkgs.stdenv.isLinux [
    # Linux-only packages
    xclip        # Clipboard support
    
  ] ++ lib.optionals pkgs.stdenv.isDarwin [
    # macOS-only packages (if any)
  ];
}
```

**Update `home/default.nix` to import it:**
```nix
{ config, pkgs, lib, username, ... }:

{
  imports = [
    ./packages.nix  # Add this line
  ];

  home = {
    username = username;
    homeDirectory = 
      if pkgs.stdenv.isDarwin 
      then "/Users/${username}" 
      else "/home/${username}";
    
    stateVersion = "24.05";
  };

  programs.home-manager.enable = true;
}
```

**Test:**
```bash
nix build .#homeConfigurations.YOUR_USERNAME.activationPackage
# Should build successfully
```

### 2.2: Create Shell Configuration

Create `home/programs/zsh.nix`:

```nix
{ config, pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    
    history = {
      size = 50000;
      save = 50000;
      ignoreDups = true;
      ignoreAllDups = true;
      ignoreSpace = true;
      share = true;
    };

    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "docker"
        "fzf"
        "sudo"
        "extract"
      ];
    };
    
    shellAliases = {
      # Modern replacements
      ls = "eza --icons";
      ll = "eza -la --icons";
      la = "eza -a --icons";
      lt = "eza --tree --icons";
      cat = "bat";
      
      # Git shortcuts
      g = "git";
      gs = "git status";
      ga = "git add";
      gc = "git commit";
      gp = "git push";
      gl = "git pull";
      gd = "git diff";
      lg = "lazygit";
      
      # Navigation
      ".." = "cd ..";
      "..." = "cd ../..";
      
      # Nix shortcuts
      nrs = "sudo nixos-rebuild switch --flake .";
      hms = "home-manager switch --flake .";
    };

    initExtra = ''
      # Initialize zoxide
      eval "$(zoxide init zsh)"
      
      # Load dotfiles environment if exists
      [[ -f ~/.dotfiles_env ]] && source ~/.dotfiles_env
      
      # Load local config if exists
      [[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
    '';
  };
}
```

**Update `home/default.nix`:**
```nix
imports = [
  ./packages.nix
  ./programs/zsh.nix  # Add this
];
```

**Test build:**
```bash
nix build .#homeConfigurations.YOUR_USERNAME.activationPackage
```

### 2.3-2.8: Create Remaining Program Configs

I'll provide each one. After creating each file, add it to imports and test build.

**Create `home/programs/starship.nix`:**
```nix
{ config, pkgs, ... }:

{
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    
    settings = {
      format = ''
        $username$hostname$directory$git_branch$git_status$nix_shell$nodejs$python$rust$golang
        $character
      '';

      character = {
        success_symbol = "[❯](bold green)";
        error_symbol = "[❯](bold red)";
      };

      directory = {
        truncation_length = 3;
        truncate_to_repo = true;
        style = "bold cyan";
      };

      git_branch = {
        symbol = " ";
        style = "bold purple";
      };

      git_status = {
        style = "bold red";
      };

      nix_shell = {
        symbol = " ";
        format = "via [$symbol$state]($style) ";
      };

      nodejs = {
        symbol = " ";
        format = "via [$symbol($version )]($style)";
      };
    };
  };
}
```

**Create `home/programs/git.nix`:**
```nix
{ config, pkgs, username, ... }:

{
  programs.git = {
    enable = true;
    
    userName = "Chris Loidolt";  # ⚠️ CHANGE THIS
    userEmail = "your-email@example.com";  # ⚠️ CHANGE THIS
    
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;
      
      # Better diffs with delta
      core.pager = "delta";
      interactive.diffFilter = "delta --color-only";
      delta = {
        navigate = true;
        light = false;
        line-numbers = true;
      };
      
      merge.conflictstyle = "diff3";
      diff.colorMoved = "default";
    };
    
    aliases = {
      st = "status";
      co = "checkout";
      br = "branch";
      ci = "commit";
      unstage = "reset HEAD --";
      last = "log -1 HEAD";
      lg = "log --oneline --graph --decorate";
    };
  };

  programs.gh = {
    enable = true;
    settings = {
      git_protocol = "ssh";
    };
  };
}
```

**Create `home/programs/tmux.nix`:**
```nix
{ config, pkgs, ... }:

{
  programs.tmux = {
    enable = true;
    
    terminal = "tmux-256color";
    escapeTime = 0;
    historyLimit = 50000;
    mouse = true;
    keyMode = "vi";
    baseIndex = 1;
    
    extraConfig = ''
      # Truecolor support
      set -as terminal-overrides ",*256col*:Tc"
      set -as terminal-overrides ",*256col*:RGB"
      
      # Focus events
      set -g focus-events on
      
      # Pane base index
      setw -g pane-base-index 1
      
      # Renumber windows
      set -g renumber-windows on
      
      # Activity monitoring
      setw -g monitor-activity on
      set -g visual-activity off
      
      # Terminal title
      set -g set-titles on
      set -g set-titles-string "#T"
      
      # Status bar
      set -g status-interval 5
      set -g status-position bottom
      set -g status-justify left
      
      # Auto rename
      setw -g automatic-rename on
    '';
  };
}
```

**Create `home/programs/neovim.nix`:**
```nix
{ config, pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    
    extraPackages = with pkgs; [
      # LSP servers
      lua-language-server
      nil  # Nix LSP
      nodePackages.typescript-language-server
      nodePackages.vscode-langservers-extracted
      
      # Formatters
      stylua
      prettierd
      nixfmt-rfc-style
      
      # Tools for telescope
      ripgrep
      fd
    ];
  };

  # Symlink your existing neovim config
  xdg.configFile."nvim".source = config.lib.file.mkOutOfStoreSymlink 
    "${config.home.homeDirectory}/dotfiles/configs/neovim";
}
```

**Create `home/programs/fzf.nix`:**
```nix
{ config, pkgs, ... }:

{
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    
    defaultCommand = "fd --type f --hidden --follow --exclude .git";
    fileWidgetCommand = "fd --type f --hidden --follow --exclude .git";
    changeDirWidgetCommand = "fd --type d --hidden --follow --exclude .git";
    
    defaultOptions = [
      "--height 40%"
      "--layout=reverse"
      "--border"
    ];
  };
}
```

**Create `home/programs/direnv.nix`:**
```nix
{ config, pkgs, ... }:

{
  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };
}
```

### 2.9: Update home/default.nix with All Imports

```nix
{ config, pkgs, lib, username, ... }:

{
  imports = [
    ./packages.nix
    ./programs/zsh.nix
    ./programs/starship.nix
    ./programs/git.nix
    ./programs/tmux.nix
    ./programs/neovim.nix
    ./programs/fzf.nix
    ./programs/direnv.nix
  ];

  home = {
    username = username;
    homeDirectory = 
      if pkgs.stdenv.isDarwin 
      then "/Users/${username}" 
      else "/home/${username}";
    
    stateVersion = "24.05";

    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      PAGER = "less";
    };
  };

  xdg.enable = true;

  # Symlink configs that aren't managed by Home Manager
  xdg.configFile = {
    "opencode".source = config.lib.file.mkOutOfStoreSymlink 
      "${config.home.homeDirectory}/dotfiles/configs/opencode";
    
    "ghostty".source = config.lib.file.mkOutOfStoreSymlink 
      "${config.home.homeDirectory}/dotfiles/configs/ghostty";
  };

  programs.home-manager.enable = true;
}
```

**Final test build:**
```bash
nix build .#homeConfigurations.YOUR_USERNAME.activationPackage

# Should build successfully with no errors
```

### 2.10: THE BIG MOMENT - Activate Home Manager! 🚀

**Before activation:**
```bash
# Make absolutely sure everything is committed
git status
git add .
git commit -m "Phase 2: All Home Manager configs created"
```

**Activate:**
```bash
# This will modify your system!
nix run home-manager/master -- switch --flake .#YOUR_USERNAME

# Watch the output carefully
# It will:
# 1. Build all packages
# 2. Create ~/.config/nvim symlink
# 3. Create ~/.config/opencode symlink
# 4. Set up zsh
# 5. Install all packages
```

**CLOSE AND REOPEN YOUR TERMINAL**

### 2.11: Validate Everything Works

```bash
# Check shell
echo $SHELL
# Should show: /nix/store/.../bin/zsh

# Check programs point to Nix store
which nvim
which tmux
which git
# All should show /nix/store/... paths

# Test programs
nvim --version
tmux -V
git --version

# Test starship prompt (should see custom prompt)

# Test aliases
ls   # Should use eza with icons
cat MIGRATION_LOG.md   # Should use bat with syntax highlighting

# Test neovim
nvim
# Should open, plugins should load

# Test tmux
tmux
# Should start, colors should work
# Exit: Ctrl+b, then d

# Check Home Manager generation
home-manager generations
# Should show current generation
```

**If everything works, commit and tag:**
```bash
git add .
git commit -m "Phase 2 complete: Home Manager active on macOS"
git tag -a phase-2-complete -m "Home Manager working on macOS"
git push origin nix-migration --tags
```

---

## Phase 3: NixOS VM Testing

[Continued in next file - this is getting long. Would you like me to continue with Phases 3-7?]

---

## Troubleshooting

### Home Manager won't activate
```bash
# Check build output for errors
nix build .#homeConfigurations.YOUR_USERNAME.activationPackage --show-trace

# Check logs
journalctl --user -xe
```

### Terminal doesn't start after activation
1. Don't panic! Open terminal from Spotlight/Applications
2. Your shell is still the old one
3. Check: `echo $SHELL`
4. Rollback if needed: `home-manager generations` then run old generation

### Neovim config not loading
```bash
# Check symlink
ls -la ~/.config/nvim
# Should point to dotfiles/configs/neovim

# Check the source path in neovim.nix
# Make sure it points to correct location
```

### Missing packages
```bash
# Add to home/packages.nix
# Then rebuild:
home-manager switch --flake .#YOUR_USERNAME
```

---

*Continue to Phases 3-7 in remaining guide sections...*
