# Graphical NixOS profile
# Desktop environment, sound, printing, fonts, and GUI applications
{ config, pkgs, lib, username, ... }:

{
  # Add docker group for graphical users (common for dev workstations)
  users.users.${username}.extraGroups = lib.mkAfter [ "docker" ];

  # Enable the KDE Plasma Desktop Environment
  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  # Configure keymap
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS for printing
  services.printing.enable = true;

  # Enable sound with pipewire
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Fonts
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

  # Graphical system packages
  environment.systemPackages = with pkgs; [
    firefox
    kdePackages.konsole
    
    # Build tools needed for compiling software (including neovim plugins)
    gcc
    gnumake
    cmake
    pkg-config
  ];

  # Enable Docker for development workstations
  virtualisation.docker.enable = true;
}
