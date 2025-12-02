# RustDesk configuration
# Remote desktop client with optional server/key/password pre-configuration
#
# RustDesk is installed via Flatpak (declaratively via nix-flatpak module).
#
# Configuration is done via secrets.nix:
#   rustdesk = {
#     server = "your-server.example.com";
#     key = "your-public-key";
#     password = "your-permanent-password";  # optional
#   };
#
# Note: The password is set via a systemd user service that runs on login.

{ pkgs, lib, config, userConfig, ... }:

let
  hasRustdeskConfig = userConfig ? rustdesk;
  hasServer = hasRustdeskConfig && userConfig.rustdesk ? server;
  hasKey = hasRustdeskConfig && userConfig.rustdesk ? key;
  hasPassword = hasRustdeskConfig && userConfig.rustdesk ? password;

  # Build the RustDesk config content in TOML format
  # Reference: https://rustdesk.com/docs/en/self-host/client-configuration/
  configContent = lib.concatStringsSep "\n" (
    lib.optional hasServer ''rendezvous_server = "${userConfig.rustdesk.server}"''
    ++ lib.optional hasKey ''key = "${userConfig.rustdesk.key}"''
  );

  # Flatpak RustDesk binary path
  flatpakRustdesk = "/var/lib/flatpak/exports/bin/com.rustdesk.RustDesk";
in
{
  # Create config file if server or key is configured
  # Note: Flatpak uses ~/.var/app/com.rustdesk.RustDesk/config/rustdesk/
  # but RustDesk also checks ~/.config/rustdesk/ on Linux
  xdg.configFile = lib.mkIf (hasServer || hasKey) {
    "rustdesk/RustDesk2.toml" = {
      text = configContent;
    };
  };

  # Also create config in Flatpak location
  home.file = lib.mkIf (hasServer || hasKey) {
    ".var/app/com.rustdesk.RustDesk/config/rustdesk/RustDesk2.toml" = {
      text = configContent;
    };
  };

  # Set permanent password via systemd user service
  # RustDesk requires the --password flag to set the permanent password
  systemd.user.services = lib.mkIf hasPassword {
    rustdesk-set-password = {
      Unit = {
        Description = "Set RustDesk permanent password";
        After = [ "graphical-session.target" ];
      };
      Service = {
        Type = "oneshot";
        # Try Flatpak first, fall back to system package
        ExecStart = toString (pkgs.writeShellScript "rustdesk-set-password" ''
          if [ -x "${flatpakRustdesk}" ]; then
            ${flatpakRustdesk} --password ${userConfig.rustdesk.password}
          elif command -v rustdesk &> /dev/null; then
            rustdesk --password ${userConfig.rustdesk.password}
          else
            echo "RustDesk not found, skipping password setup"
          fi
        '');
        RemainAfterExit = true;
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
  };
}
