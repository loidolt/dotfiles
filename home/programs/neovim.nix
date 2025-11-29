{ pkgs, ... }:

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
      ripgrep  # For telescope grep
      fd  # For telescope file finder
      tree-sitter  # For better syntax highlighting
    ];
  };
  
  # Symlink to existing neovim config
  xdg.configFile."nvim" = {
    source = ../../configs/neovim;
    recursive = true;
  };
}
