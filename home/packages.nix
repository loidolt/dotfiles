{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Core utilities
    git
    curl
    wget
    vim
    tmux
    htop
    tree
    jq
    unzip
    
    # Modern CLI tools
    ripgrep      # Fast grep alternative
    fd           # Fast find alternative
    bat          # Cat with syntax highlighting
    fzf          # Fuzzy finder
    eza          # Modern ls replacement
    zoxide       # Smart cd command
    
    # macOS GNU utilities (better than BSD versions)
    coreutils
    gnused
    gnutar
    watch
    
    # Development tools
    nodejs_20    # Node.js LTS
    bun          # Fast JavaScript runtime
    devbox       # Project-specific dev environments
    
    # Node global packages (we'll manage these with Nix instead)
    nodePackages.typescript
    # ts-node removed - use NodeJS 22+ built-in TypeScript support
    nodePackages.prettier
    nodePackages.eslint
    
    # Additional useful tools
    gh           # GitHub CLI
    delta        # Better git diffs
    lazygit      # Terminal UI for git
    
    # System monitoring and management
    btop         # Better system monitor
    
    # Network and remote access
    mosh         # Mobile shell for unstable connections
    
    # Archive utilities
    p7zip        # 7-Zip archive support
    
    # Document processing
    pandoc       # Universal document converter
    
    # Container management
    lazydocker   # Docker TUI
    
    # Editors and IDEs
    vscode       # Visual Studio Code
    
    # Fonts (Nerd Fonts for icons in terminal)
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
    nerd-fonts.meslo-lg
  ];
}
