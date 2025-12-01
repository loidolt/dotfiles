# Shared font configuration for all platforms
#
# This module provides consistent font configuration across NixOS, Darwin, and WSL.
# Import this in your system configuration (not home-manager, as fonts are system-level).
{ lib, pkgs, ... }:

{
  fonts = {
    packages = with pkgs; [
      nerd-fonts.fira-code
      nerd-fonts.jetbrains-mono
      nerd-fonts.meslo-lg
    ];
  } // lib.optionalAttrs pkgs.stdenv.isLinux {
    # Linux-specific fontconfig settings
    fontconfig = {
      enable = true;
      defaultFonts = {
        monospace = [ "JetBrainsMono Nerd Font" ];
        sansSerif = [ "DejaVu Sans" ];
        serif = [ "DejaVu Serif" ];
      };
    };
  };
}
