# NixOS Desktop (x86_64) Configuration
#
# Graphical desktop with KDE Plasma for x86_64 systems.
# Intended for: VMware, VirtualBox, x86_64 bare metal
#
# SETUP:
#   1. Run 'sudo nixos-generate-config' on the target machine
#   2. Rebuild with: sudo nixos-rebuild switch --flake .#nixos-desktop-x86 --impure
#
# The --impure flag is required because we import hardware config from /etc/nixos/

{ lib, ... }:

{
  imports = [
    # Import machine-specific hardware config from standard NixOS location
    /etc/nixos/hardware-configuration.nix
    ../../modules/shared/nix-settings.nix
    ../../modules/shared/fonts.nix
    ../../modules/nixos/base.nix
    ../../modules/nixos/graphical.nix
  ];

  # Host-specific configuration
  networking.hostName = "nixos-desktop-x86";

  # Ensure we're on x86_64
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  # Override state version for this specific host
  system.stateVersion = "25.05";
}
