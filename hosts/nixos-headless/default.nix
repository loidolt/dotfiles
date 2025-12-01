# NixOS Headless (x86_64) Configuration
#
# Minimal server configuration without GUI.
# Intended for: Servers, VPS, headless VMs
#
# SETUP:
#   1. Generate hardware config on target: sudo nixos-generate-config --show-hardware-config > hardware-configuration.nix
#   2. Copy to this directory and commit to repo
#   3. Rebuild with: sudo nixos-rebuild switch --flake .#nixos-headless

{ lib, ... }:

{
  imports = [
    # Machine-specific hardware config (committed to repo for reproducibility)
    ./hardware-configuration.nix
    ../../modules/shared/nix-settings.nix
    ../../modules/nixos/base.nix
    ../../modules/nixos/headless.nix
  ];

  # Host-specific configuration
  networking.hostName = "nixos-headless";

  # Ensure we're on x86_64
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  # Override state version for this specific host
  system.stateVersion = "25.05";
}
