# nixos-desktop Host-Specific Configuration
#
# ARM64 (Parallels/Apple Silicon) specific settings, packages, and overrides.
# This file is for customizations that only apply to this specific machine.
#
# Common customizations:
#   - VM guest tools and drivers
#   - Host-specific packages
#   - Service overrides

{ config, pkgs, lib, ... }:

{
  # ==========================================================================
  # Parallels/ARM64 VM Configuration
  # ==========================================================================

  # Parallels tools are typically handled by hardware-configuration.nix
  # Add any additional VM integration settings here

  # ==========================================================================
  # Host-Specific Packages
  # ==========================================================================

  environment.systemPackages = with pkgs; [
    # Add any ARM64/Parallels-specific tools here
  ];

  # ==========================================================================
  # Service Overrides
  # ==========================================================================

  # Example: Disable printing if not needed
  # services.printing.enable = false;

  # ==========================================================================
  # Hardware-Specific Settings
  # ==========================================================================

  # VM typically doesn't need firmware updates
  hardware.enableRedistributableFirmware = lib.mkDefault false;
}
