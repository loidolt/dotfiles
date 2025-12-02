# RustDesk configuration
# Remote desktop client - runs as a background service for unattended access
#
# RustDesk is installed via Flatpak (declaratively via nix-flatpak module).
# Note: The nixpkgs package has a cargo-auditable build bug, so we use Flatpak.
#
# Configuration (server, key, password) is done via the RustDesk GUI:
#   Settings → Network → ID/Relay Server

{ pkgs, lib, config, ... }:

let
  # Flatpak RustDesk binary path
  flatpakRustdesk = "/var/lib/flatpak/exports/bin/com.rustdesk.RustDesk";
in
{
  # Auto-start RustDesk service on graphical login
  # This allows unattended remote access without keeping the window open
  systemd.user.services.rustdesk = {
    Unit = {
      Description = "RustDesk Remote Desktop Service";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      Type = "simple";
      ExecStart = "${flatpakRustdesk} --service";
      Restart = "on-failure";
      RestartSec = 5;
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}
