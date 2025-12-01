# NixOS Desktop (ARM64) Configuration
#
# Graphical desktop with KDE Plasma for ARM64 systems.
# Intended for: Parallels on Apple Silicon, ARM64 bare metal
#
# SETUP:
#   1. Generate hardware config on target: sudo nixos-generate-config --show-hardware-config > hardware-configuration.nix
#   2. Copy to this directory and commit to repo
#   3. Rebuild with: sudo nixos-rebuild switch --flake .#nixos-desktop

{ lib, ... }:

{
  imports = [
    # Machine-specific hardware config (committed to repo for reproducibility)
    ./hardware-configuration.nix
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
