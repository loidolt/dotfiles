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
    
    # Environment variables
    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      PAGER = "bat";
    };
  };

  # Let Home Manager manage itself
  programs.home-manager.enable = true;
  
  # Enable XDG directories
  xdg.enable = true;
  
  # Symlink additional configs
  xdg.configFile = {
    "opencode" = {
      source = ../configs/opencode;
      recursive = true;
    };
    "ghostty" = {
      source = ../configs/ghostty;
      recursive = true;
    };
  };
}
