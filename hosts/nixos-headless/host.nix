# nixos-headless Host-Specific Configuration
#
# Server-specific settings, packages, and overrides.
# This file is for customizations that only apply to this specific machine.
#
# Common customizations:
#   - Server-specific packages
#   - Service configurations
#   - Security hardening

{ config, pkgs, lib, ... }:

{
  # ==========================================================================
  # Host-Specific Packages
  # ==========================================================================

  environment.systemPackages = with pkgs; [
    # Server monitoring and management
    # Add any server-specific tools here
  ];

  # ==========================================================================
  # Service Overrides
  # ==========================================================================

  # Example: Configure specific services for this server
  # services.nginx.enable = true;

  # ==========================================================================
  # Security Hardening
  # ==========================================================================

  # Example: More restrictive SSH settings for servers
  # services.openssh.settings.PasswordAuthentication = false;

  # ==========================================================================
  # Network Configuration
  # ==========================================================================

  # Add any host-specific firewall rules
  # networking.firewall.allowedTCPPorts = [ 80 443 ];
}
