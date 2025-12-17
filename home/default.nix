{ config, pkgs, lib, userConfig, dotfilesPath, ... }:

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
    ./programs/navi.nix
  ];

  home = {
    username = userConfig.username;
    homeDirectory =
      if pkgs.stdenv.isDarwin
      then "/Users/${userConfig.username}"
      else "/home/${userConfig.username}";

    stateVersion = "25.05";

    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      PAGER = "bat";
    };
  };

  programs.home-manager.enable = true;
  xdg.enable = true;

  # Nix settings for Home Manager standalone
  # Note: This configuration requires --impure flag because:
  # 1. ssh-hosts.nix is gitignored for privacy (conditional import)
  # 2. builtins.pathExists is used for conditional imports
  nix = {
    package = pkgs.nix;
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };
    gc = {
      automatic = true;
      options = "--delete-older-than 30d";
    };
  };

  # Config file symlinks
  xdg.configFile = {
    "opencode" = {
      source = ../configs/opencode;
      recursive = true;
    };
    "ghostty" = {
      source = ../configs/ghostty;
      recursive = true;
    };
    "navi/cheats" = {
      source = ../configs/navi/cheats;
      recursive = true;
    };
  };
}
