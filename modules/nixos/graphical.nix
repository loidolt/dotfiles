# Graphical NixOS profile
# Desktop environment, sound, printing, and GUI applications
#
# Note: Fonts are now handled by the shared fonts module

{ config, pkgs, lib, username, userConfig, ... }:

{
  # Add docker group for graphical users (common for dev workstations)
  users.users.${username}.extraGroups = lib.mkAfter [ "docker" ];

  # Enable the KDE Plasma Desktop Environment
  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  # Configure keymap
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS for printing
  services.printing.enable = lib.mkDefault true;

  # Enable sound with pipewire
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Graphical system packages
  environment.systemPackages = with pkgs; [
    firefox
    kdePackages.konsole

    # Build tools needed for compiling software (including neovim plugins)
    gcc
    gnumake
    cmake
    pkg-config

  ];

  # Enable Flatpak for applications not well-supported in nixpkgs
  # RustDesk: nixpkgs package has cargo-auditable build bug, using Flatpak instead
  # TODO: Switch to nixpkgs when https://github.com/NixOS/nixpkgs/issues/... is fixed
  services.flatpak = {
    enable = lib.mkDefault true;

    # Flatpak packages (installed declaratively via nix-flatpak)
    packages = [
      "com.rustdesk.RustDesk"
    ];

    # Update flatpaks on system activation
    update.onActivation = true;
  };

  # ==========================================================================
  # RustDesk Service Configuration
  # ==========================================================================
  # RustDesk needs to run as a system service for unattended access.
  # The service starts after the display manager and provides remote access.
  #
  # After installation, configure RustDesk via the GUI:
  #   1. Open RustDesk
  #   2. Settings → Network → ID/Relay Server (configure your server)
  #   3. Settings → Security → Set permanent password

  systemd.services.rustdesk = {
    description = "RustDesk Remote Desktop Service";
    documentation = [ "https://rustdesk.com/docs" ];

    # Start after display manager is ready
    after = [ "network.target" "display-manager.service" ];
    wants = [ "network.target" ];
    wantedBy = [ "graphical.target" ];

    # Flatpak needs access to the user's session for screen sharing
    # We run as the primary user to access their X/Wayland session
    serviceConfig = {
      Type = "simple";
      User = username;
      Group = "users";

      # Environment for Flatpak and display access
      Environment = [
        "DISPLAY=:0"
        "XDG_RUNTIME_DIR=/run/user/1000"
      ];

      # Run RustDesk in service mode via Flatpak
      ExecStart = "/var/lib/flatpak/exports/bin/com.rustdesk.RustDesk --service";

      # Restart on failure
      Restart = "on-failure";
      RestartSec = 5;

      # Security hardening (limited due to Flatpak requirements)
      NoNewPrivileges = false;  # Flatpak may need this
      ProtectSystem = "strict";
      ProtectHome = "read-only";
      ReadWritePaths = [
        "/home/${username}/.var/app/com.rustdesk.RustDesk"
        "/tmp"
      ];
    };
  };

  # Firewall rules for RustDesk
  # RustDesk uses TCP 21115-21117 for relay and UDP 21116 for hole punching
  # These are only needed if connecting directly (not via relay server)
  networking.firewall = {
    allowedTCPPorts = [ 21115 21116 21117 21118 21119 ];
    allowedUDPPorts = [ 21116 ];
  };

  # Enable Docker for development workstations
  virtualisation.docker.enable = lib.mkDefault true;
}
