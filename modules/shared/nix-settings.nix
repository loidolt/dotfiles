# Shared Nix settings for all platforms (NixOS, Darwin, Home Manager)
#
# This module provides consistent Nix configuration across all systems.
# Import this in your system or home-manager configuration.
#
# Note: Some settings have platform-specific implementations:
# - Darwin uses nix.optimise.automatic instead of auto-optimise-store
# - Darwin uses interval-based GC instead of dates
{ lib, pkgs, ... }:

let
  isDarwin = pkgs.stdenv.isDarwin;
in
{
  nix = {
    settings = {
      # Enable flakes and nix-command
      experimental-features = [ "nix-command" "flakes" ];

      # Binary caches for faster builds
      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];

      # Build settings
      max-jobs = "auto";
      cores = 0; # Use all available cores

      # Increase download buffer size to prevent warning during large fetches
      # Default is 64MB, increase to 256MB for large packages like rustdesk
      download-buffer-size = 256 * 1024 * 1024;
    } // lib.optionalAttrs (!isDarwin) {
      # Linux/NixOS specific: optimize store automatically
      auto-optimise-store = true;
    };

    # Garbage collection - platform-specific syntax
    gc = {
      automatic = true;
      options = "--delete-older-than 30d";
    } // (if isDarwin then {
      # Darwin uses interval-based scheduling
      interval = { Weekday = 0; Hour = 0; Minute = 0; };
    } else {
      # NixOS uses systemd timer dates
      dates = lib.mkDefault "weekly";
    });
  } // lib.optionalAttrs isDarwin {
    # Darwin-specific: use optimise.automatic instead of auto-optimise-store
    optimise.automatic = true;
  };
}
