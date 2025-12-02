# RustDesk configuration (Home Manager)
# Remote desktop client configuration for user session
#
# RustDesk is installed via Flatpak (declaratively via nix-flatpak module in graphical.nix).
# Note: The nixpkgs package has a cargo-auditable build bug, so we use Flatpak.
#
# The RustDesk SERVICE runs as a NixOS system service (see graphical.nix).
# This home-manager module handles user-session autostart of the GUI.
#
# Configuration (server, key, password) is done via the RustDesk GUI:
#   Settings → Network → ID/Relay Server
#
# IMPORTANT: After first run, configure RustDesk:
#   1. Open RustDesk GUI
#   2. Go to Settings → Network → ID/Relay Server
#   3. Enter your relay server details
#   4. Set a permanent password in Settings → Security

{ pkgs, lib, config, ... }:

{
  # Only apply on Linux (RustDesk Flatpak is Linux-only)
  config = lib.mkIf pkgs.stdenv.isLinux {
    # XDG autostart entry for RustDesk GUI (optional - for tray icon)
    # The actual service runs at system level; this just provides the tray icon
    xdg.desktopEntries.rustdesk-tray = {
      name = "RustDesk Tray";
      comment = "RustDesk Remote Desktop Tray Icon";
      exec = "flatpak run com.rustdesk.RustDesk";
      icon = "com.rustdesk.RustDesk";
      terminal = false;
      categories = [ "Network" "RemoteAccess" ];
      settings = {
        X-GNOME-Autostart-enabled = "true";
        X-KDE-autostart-after = "panel";
      };
    };
  };
}
