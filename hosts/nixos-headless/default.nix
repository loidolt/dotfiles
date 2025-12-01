{ config, pkgs, inputs, username, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos/base.nix
    ../../modules/nixos/headless.nix
  ];

  # Host-specific configuration
  networking.hostName = "nixos-headless";

  # Override state version for this specific host
  system.stateVersion = "25.05";
}
