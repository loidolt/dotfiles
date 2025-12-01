# NixOS Headless (x86_64) Configuration
#
# Minimal server configuration without GUI.
# Intended for: Servers, VPS, headless VMs
#
# SETUP:
#   1. Run 'sudo nixos-generate-config' on the target machine
#   2. Rebuild with: sudo nixos-rebuild switch --flake .#nixos-headless --impure
#
# The --impure flag is required because we import hardware config from /etc/nixos/

{ lib, ... }:

{
  imports = [
    # Import machine-specific hardware config from standard NixOS location
    /etc/nixos/hardware-configuration.nix
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
