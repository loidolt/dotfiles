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
  
  # Nix configuration
  nix = {
    # Use the Nix package from nixpkgs (only on standalone home-manager, not on NixOS)
    # On NixOS, the system manages the Nix package, so we don't set it here
    package = lib.mkIf (!pkgs.stdenv.isLinux) pkgs.nix;
    
    # Enable automatic garbage collection
    gc = {
      automatic = true;
      options = "--delete-older-than 30d";
    };
    
    # Nix settings
    settings = {
      # Enable flakes and nix-command
      experimental-features = [ "nix-command" "flakes" ];
      
      # Optimize store automatically
      auto-optimise-store = true;
      
      # Use binary cache
      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
      
      # Build settings
      max-jobs = "auto";
      cores = 0; # Use all available cores
    };
  };
  
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
