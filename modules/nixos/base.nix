# Shared NixOS base configuration
# Common settings for all NixOS systems (graphical and headless)
#
# Note: This module expects 'username' and 'userConfig' to be passed via specialArgs

{ config, pkgs, lib, username, userConfig, ... }:

{
  # Bootloader
  boot.loader.systemd-boot.enable = lib.mkDefault true;
  boot.loader.efi.canTouchEfiVariables = lib.mkDefault true;

  # Networking defaults
  networking.networkmanager.enable = lib.mkDefault true;

  # Timezone and internationalization (from user config)
  time.timeZone = lib.mkDefault userConfig.timezone;
  i18n.defaultLocale = lib.mkDefault userConfig.locale;
  i18n.extraLocaleSettings = lib.mkDefault {
    LC_ADDRESS = userConfig.locale;
    LC_IDENTIFICATION = userConfig.locale;
    LC_MEASUREMENT = userConfig.locale;
    LC_MONETARY = userConfig.locale;
    LC_NAME = userConfig.locale;
    LC_NUMERIC = userConfig.locale;
    LC_PAPER = userConfig.locale;
    LC_TELEPHONE = userConfig.locale;
    LC_TIME = userConfig.locale;
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
    enable = lib.mkDefault true;
    settings = {
      PermitRootLogin = lib.mkDefault "no";
      PasswordAuthentication = lib.mkDefault true;
    };
  };

  # Firewall
  networking.firewall.enable = lib.mkDefault true;
  networking.firewall.allowedTCPPorts = lib.mkDefault [ 22 ];

  # System state version - should be overridden per-host
  system.stateVersion = lib.mkDefault "25.05";
}
