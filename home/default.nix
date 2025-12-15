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
    ./programs/navi.nix
    ./programs/opencode.nix
    ./programs/claude.nix
  ];

  home = {
    username = username;
    homeDirectory =
      if pkgs.stdenv.isDarwin
      then "/Users/${username}"
      else "/home/${username}";

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
