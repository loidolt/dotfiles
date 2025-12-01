# lra-chrislw Host-Specific Configuration
#
# Proxmox VM-specific settings, packages, and overrides.
# This file is for customizations that only apply to this specific machine.
#
# Common customizations:
#   - VM guest tools and drivers
#   - Host-specific packages
#   - Service overrides
#   - Hardware-specific settings

{ config, pkgs, lib, ... }:

{
  # ==========================================================================
  # Bootloader - BIOS/Legacy boot (no EFI on this VM)
  # ==========================================================================

  boot.loader.systemd-boot.enable = false;
  boot.loader.efi.canTouchEfiVariables = false;
  boot.loader.grub = {
    enable = true;
    device = "/dev/sda";  # Adjust if your boot disk is different (check with lsblk)
  };

  # ==========================================================================
  # VM Guest Configuration
  # ==========================================================================

  # QEMU guest agent for Proxmox integration
  services.qemuGuest.enable = true;

  # Spice agent for better VM integration (clipboard, resolution, etc.)
  services.spice-vdagentd.enable = true;

  # ==========================================================================
  # Host-Specific Packages
  # ==========================================================================

  environment.systemPackages = with pkgs; [
    # VM utilities
    spice-vdagent

    # Add any Proxmox/VM-specific tools here
    # Example: virt-viewer, looking-glass-client, etc.
  ];

  # ==========================================================================
  # Service Overrides
  # ==========================================================================

  # Example: Disable printing if not needed on this VM
  # services.printing.enable = false;

  # Example: Disable Docker if not needed
  # virtualisation.docker.enable = false;

  # ==========================================================================
  # Hardware-Specific Settings
  # ==========================================================================

  # VM typically doesn't need firmware updates
  hardware.enableRedistributableFirmware = lib.mkDefault false;

  # ==========================================================================
  # Network Overrides
  # ==========================================================================

  # Add any host-specific firewall rules
  # networking.firewall.allowedTCPPorts = [ ... ];
}
