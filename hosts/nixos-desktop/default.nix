# NixOS Desktop (ARM64) Configuration
#
# Graphical desktop with KDE Plasma for ARM64 systems.
# Intended for: Parallels on Apple Silicon, ARM64 bare metal
#
# SETUP:
#   1. Run 'sudo nixos-generate-config' on the target machine
#   2. Rebuild with: sudo nixos-rebuild switch --flake .#nixos-desktop --impure
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
  networking.hostName = "nixos-desktop";

  # Ensure we're on ARM64
  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";

  # Override state version for this specific host
  system.stateVersion = "25.05";
}
