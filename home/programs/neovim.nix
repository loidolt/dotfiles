{ pkgs, lib, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    
    # Language servers and tools that neovim needs
    extraPackages = with pkgs; [
      # LSP servers
      lua-language-server
      nil  # Nix LSP
      nodePackages.typescript-language-server
      nodePackages.vscode-langservers-extracted  # HTML, CSS, JSON, ESLint
      nodePackages.bash-language-server
      nodePackages.yaml-language-server
      
      # Formatters
      stylua  # Lua formatter
      nixpkgs-fmt  # Nix formatter
      nodePackages.prettier  # JS/TS/JSON/etc formatter
      shfmt  # Shell script formatter
      
      # Tools
      # Note: ripgrep and fd are installed globally in packages.nix
      # They're required for telescope grep and file finder functionality
      ripgrep  # For telescope grep
      fd  # For telescope file finder
      tree-sitter  # For better syntax highlighting
    ];
  };
  
  # Symlink individual files, excluding lazy-lock.json
  # This allows lazy.nvim to manage its lockfile while keeping config in sync
  xdg.configFile."nvim/init.lua".source = ../../configs/neovim/init.lua;
  xdg.configFile."nvim/lua".source = ../../configs/neovim/lua;
  
  # Create an empty lazy-lock.json that can be written to
  # Don't manage it with Home Manager so lazy.nvim can update it
  home.activation.createNvimLockfile = lib.hm.dag.entryAfter ["writeBoundary"] ''
    mkdir -p $HOME/.config/nvim
    if [ ! -f $HOME/.config/nvim/lazy-lock.json ]; then
      touch $HOME/.config/nvim/lazy-lock.json
    fi
  '';
}
