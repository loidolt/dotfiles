# Headless/Minimal NixOS profile
# Server-oriented configuration without GUI

{ config, pkgs, lib, ... }:

{
  # Headless-specific packages (lightweight tools for server management)
  # Note: htop is already in base.nix
  environment.systemPackages = with pkgs; [
    # System monitoring
    btop
    iotop

    # Network tools
    dig
    nmap
    tcpdump

    # Build tools (minimal set for development)
    gcc
    gnumake
  ];

  # Disable unnecessary services for headless
  documentation.nixos.enable = lib.mkDefault false;

  # Console configuration (no GUI needed)
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  # More aggressive memory management for servers
  boot.kernel.sysctl = {
    "vm.swappiness" = 10;
    "vm.vfs_cache_pressure" = 50;
  };

  # Enable automatic security updates
  system.autoUpgrade = {
    enable = lib.mkDefault false; # Enable per-host if desired
    allowReboot = lib.mkDefault false;
  };
}
