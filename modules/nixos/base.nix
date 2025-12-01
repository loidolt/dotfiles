# Shared NixOS base configuration
# Common settings for all NixOS systems (graphical and headless)
{ config, pkgs, lib, username, ... }:

{
  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Networking defaults
  networking.networkmanager.enable = true;

  # Timezone and internationalization
  time.timeZone = "America/Denver";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Define user account
  users.users.${username} = {
    isNormalUser = true;
    description = username;
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.zsh;
  };

  # Enable zsh system-wide
  programs.zsh.enable = true;

  # Nix configuration and optimization
  nix = {
    settings = {
      # Enable flakes
      experimental-features = [ "nix-command" "flakes" ];
      
      # Optimize store automatically
      auto-optimise-store = true;
      
      # Use binary caches
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
    
    # Automatic garbage collection
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Base system packages (minimal set for all systems)
  environment.systemPackages = with pkgs; [
    vim
    wget
    curl
    git
    htop
    tree
  ];

  # Enable SSH
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = true;
    };
  };

  # Firewall
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 22 ];

  # System state version - should be overridden per-host
  system.stateVersion = lib.mkDefault "25.05";
}
