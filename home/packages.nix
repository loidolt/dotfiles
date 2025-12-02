{ pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    # Core utilities
    git curl wget vim tmux tree jq unzip

    # Modern CLI tools
    ripgrep fd bat fzf eza zoxide

    # Development tools
    nodejs_20 bun devbox
    nodePackages.typescript nodePackages.prettier nodePackages.eslint
    lazygit

    # System monitoring
    btop

    # Network & archive tools
    mosh p7zip

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

    # Fonts (Home Manager manages these on Linux)
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
    nerd-fonts.meslo-lg
  ];

  # On macOS, install fonts via Homebrew or manually:
  #   brew install --cask font-fira-code-nerd-font font-jetbrains-mono-nerd-font font-meslo-lg-nerd-font
  # Nix fonts on macOS require system-level installation which we avoid in standalone HM mode.
}
