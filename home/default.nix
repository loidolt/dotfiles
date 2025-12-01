{ config, pkgs, lib, username, userConfig, ... }:

{
  imports = [
    ./dotfiles.nix
    ./packages.nix
    ./programs/zsh.nix
    ./programs/starship.nix
    ./programs/git.nix
    ./programs/ssh.nix
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

    stateVersion = "25.05";

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

  # Nix configuration for standalone Home Manager
  # Note: When used with nix-darwin or NixOS (useGlobalPkgs = true),
  # the system manages nix.package, so we use mkDefault to allow override
  nix = {
    # Use the Nix package from nixpkgs only in standalone Home Manager on macOS
    # When integrated with nix-darwin or NixOS, the system manages this
    package = lib.mkDefault pkgs.nix;

    # Enable automatic garbage collection
    gc = {
      automatic = true;
      options = "--delete-older-than 30d";
    };

    # Nix settings - these complement the system-level settings
    settings = {
      # Enable flakes and nix-command
      experimental-features = [ "nix-command" "flakes" ];

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
