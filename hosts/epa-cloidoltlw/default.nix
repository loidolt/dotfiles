# epa-cloidoltlw - NixOS Desktop (x86_64) on Bare Metal
#
# Graphical desktop with KDE Plasma for physical hardware.
#
# SETUP:
#   1. Generate hardware config on target: sudo nixos-generate-config --show-hardware-config > hardware-configuration.nix
#   2. Copy to this directory and commit to repo
#   3. Rebuild with: sudo nixos-rebuild switch --flake .#epa-cloidoltlw

{ lib, ... }:

{
  imports = [
    # Machine-specific hardware config (committed to repo for reproducibility)
    ./hardware-configuration.nix
    # Host-specific packages, overrides, and customizations
    ./host.nix
    # Shared modules
    ../../modules/shared/nix-settings.nix
    ../../modules/shared/fonts.nix
    ../../modules/nixos/base.nix
    ../../modules/nixos/graphical.nix
  ];

  # Host-specific configuration
  networking.hostName = "epa-cloidoltlw";

  # x86_64 Linux
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  # System state version
  system.stateVersion = "25.05";
}
