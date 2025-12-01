# WSL2 NixOS Configuration
#
# Windows Subsystem for Linux configuration.
# This integrates with the base NixOS modules while adding WSL-specific settings.
#
# SETUP:
#   1. Install NixOS-WSL following https://github.com/nix-community/NixOS-WSL
#   2. Rebuild with: sudo nixos-rebuild switch --flake .#wsl

{ lib, pkgs, username, userConfig, ... }:

{
  imports = [
    ../../modules/shared/nix-settings.nix
    ../../modules/shared/fonts.nix
    # Note: We don't import base.nix here because WSL has different requirements
    # (no bootloader, different networking, etc.)
  ];

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

  # Networking - WSL handles most networking
  networking.hostName = "wsl-nixos";

  # Timezone and internationalization (from user config)
  time.timeZone = lib.mkDefault userConfig.timezone;
  i18n.defaultLocale = lib.mkDefault userConfig.locale;

  # Define user account
  users.users.${username} = {
    isNormalUser = true;
    description = username;
    extraGroups = [ "wheel" "docker" ];
    shell = pkgs.zsh;
  };

  # Enable zsh system-wide
  programs.zsh.enable = true;

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

  # Enable Docker
  virtualisation.docker.enable = true;

  # Enable SSH
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = lib.mkDefault true;
    };
  };

  # System state version
  system.stateVersion = "25.05";
}
