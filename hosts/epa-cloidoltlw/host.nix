# epa-cloidoltlw Host-Specific Configuration
#
# Bare metal-specific settings, packages, and overrides.
# This file is for customizations that only apply to this specific machine.
#
# Common customizations:
#   - GPU drivers (NVIDIA, AMD)
#   - Host-specific packages
#   - Service overrides
#   - Hardware-specific settings (firmware, sensors, etc.)

{ config, pkgs, lib, ... }:

{
  # ==========================================================================
  # Hardware Configuration
  # ==========================================================================

  # Enable firmware updates
  hardware.enableRedistributableFirmware = true;

  # CPU microcode updates (uncomment the appropriate one)
  # hardware.cpu.intel.updateMicrocode = true;
  # hardware.cpu.amd.updateMicrocode = true;

  # ==========================================================================
  # GPU Configuration
  # ==========================================================================

  # NVIDIA GPU (uncomment if using NVIDIA)
  # services.xserver.videoDrivers = [ "nvidia" ];
  # hardware.nvidia = {
  #   modesetting.enable = true;
  #   powerManagement.enable = false;
  #   open = false;  # Use proprietary driver
  #   nvidiaSettings = true;
  #   package = config.boot.kernelPackages.nvidiaPackages.stable;
  # };
  # hardware.graphics.enable = true;

  # AMD GPU (uncomment if using AMD)
  # services.xserver.videoDrivers = [ "amdgpu" ];
  # hardware.graphics.enable = true;

  # ==========================================================================
  # Host-Specific Packages
  # ==========================================================================

  environment.systemPackages = with pkgs; [
    # Hardware monitoring
    lm_sensors
    smartmontools

    # System utilities for bare metal
    pciutils
    usbutils
    dmidecode

    # Add any machine-specific tools here
  ];

  # ==========================================================================
  # Service Overrides
  # ==========================================================================

  # Example: Enable printing for physical workstation
  # services.printing.enable = true;

  # Example: Enable Bluetooth
  # hardware.bluetooth.enable = true;

  # ==========================================================================
  # Power Management (for physical hardware)
  # ==========================================================================

  # Thermald for Intel CPUs
  # services.thermald.enable = true;

  # TLP for laptop power management
  # services.tlp.enable = true;

  # ==========================================================================
  # Network Overrides
  # ==========================================================================

  # Add any host-specific firewall rules
  # networking.firewall.allowedTCPPorts = [ ... ];
}
