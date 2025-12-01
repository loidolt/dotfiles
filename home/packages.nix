{ pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    # Core utilities (all platforms)
    git
    curl
    wget
    vim
    tmux
    htop
    tree
    jq
    unzip
    
    # Modern CLI tools (all platforms)
    ripgrep
    fd
    bat
    fzf
    eza
    zoxide
    
    # Development tools (all platforms)
    nodejs_20
    bun
    devbox
    nodePackages.typescript
    nodePackages.prettier
    nodePackages.eslint
    gh
    delta
    lazygit
    
    # System monitoring (all platforms)
    btop
    
    # Network tools (all platforms)
    mosh
    
    # Archive utilities (all platforms)
    p7zip
    
    # Document processing (all platforms)
    pandoc
    
    # Container management (all platforms)
    lazydocker
    
  ] ++ lib.optionals pkgs.stdenv.isDarwin [
    # macOS-specific packages
    # GNU utilities (better than BSD versions on macOS)
    coreutils
    gnused
    gnutar
    watch
    
    # Editors - VSCode works better via Homebrew on macOS
    # vscode
    
  ] ++ lib.optionals pkgs.stdenv.isLinux [
    # Linux-specific packages
    vscode  # VSCode works well via Nix on Linux
    
    # Fonts for Home Manager on Linux (standalone mode)
    # When using NixOS or nix-darwin, fonts should be in system config
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
    nerd-fonts.meslo-lg
  ];
}
