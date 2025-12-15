{ pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    # Core utilities
    git curl wget vim tmux tree jq unzip

    # Modern CLI tools
    ripgrep fd bat fzf eza zoxide navi
    glow yq-go tldr dust hyperfine jless procs xh lazysql

    # Development tools
    nodejs_20 bun devbox
    nodePackages.typescript nodePackages.prettier nodePackages.eslint
    lazygit

    # Python development tools
    python3
    pipx
    python3Packages.black
    python3Packages.flake8
    python3Packages.isort
    python3Packages.autopep8

    # Cloud & Infrastructure
    google-cloud-sdk

    # System monitoring
    btop

    # Network & archive tools
    mosh p7zip
    
    # Network diagnostics & tools
    bind # nslookup, dig, host, nslookup
    nmap
    tcpdump
    whois
    netcat-gnu

    # Document processing
    pandoc

    # Container management
    lazydocker

  ] ++ lib.optionals pkgs.stdenv.isDarwin [
    # macOS-specific (GNU utils)
    coreutils gnused gnutar watch

  ] ++ lib.optionals pkgs.stdenv.isLinux [
    # Linux-specific
    vscode

    # Network tools
    iproute2 # ip, ss, and other modern network tools
    traceroute

    # Fonts (Home Manager manages these on Linux)
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
    nerd-fonts.meslo-lg
  ];

  # On macOS, install fonts via Homebrew or manually:
  #   brew install --cask font-fira-code-nerd-font font-jetbrains-mono-nerd-font font-meslo-lg-nerd-font
  # Nix fonts on macOS require system-level installation which we avoid in standalone HM mode.
}
