{ config, pkgs, lib, username, ... }:

{
  # WSL-specific settings
  wsl = {
    enable = true;
    defaultUser = username;
    startMenuLaunchers = true;
    
    # Enable integration with Windows
    wslConf = {
      automount.root = "/mnt";
      network.generateHosts = true;
      network.generateResolvConf = true;
    };
  };

  # Networking
  networking = {
    hostName = "wsl-nixos";
    # WSL handles networking, so disable networkmanager
  };

  # Timezone and internationalization
  time.timeZone = "America/Denver";
  i18n.defaultLocale = "en_US.UTF-8";

  # Define user account
  users.users.${username} = {
    isNormalUser = true;
    description = username;
    extraGroups = [ "wheel" "docker" ];
    shell = pkgs.zsh;
  };

  # Enable zsh system-wide
  programs.zsh.enable = true;

  # Nix configuration
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
      
      # Binary caches
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
      cores = 0;
    };
    
    # Garbage collection
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # System packages
  environment.systemPackages = with pkgs; [
    vim
    wget
    curl
    git
    
    # Build tools
    gcc
    gnumake
    cmake
    pkg-config
    
    # WSL utilities
    wslu
  ];

  # Fonts (using modern nerd-fonts syntax)
  fonts = {
    packages = with pkgs; [
      nerd-fonts.fira-code
      nerd-fonts.jetbrains-mono
      nerd-fonts.meslo-lg
    ];
    
    fontconfig = {
      enable = true;
      defaultFonts = {
        monospace = [ "JetBrainsMono Nerd Font" ];
        sansSerif = [ "DejaVu Sans" ];
        serif = [ "DejaVu Serif" ];
      };
    };
  };

  # Enable Docker
  virtualisation.docker.enable = true;

  # Enable SSH
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = true;
    };
  };

  # System state version
  system.stateVersion = "24.05";
}
