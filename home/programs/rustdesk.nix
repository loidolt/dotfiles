# RustDesk configuration
# Remote desktop client with optional server/key/password pre-configuration
#
# RustDesk is installed via Flatpak (declaratively via nix-flatpak module).
# Note: The nixpkgs package has a cargo-auditable build bug, so we use Flatpak.
#
# Configuration is done via secrets.nix:
#   rustdesk = {
#     server = "your-server.example.com";
#     key = "your-public-key";
#     password = "your-permanent-password";  # optional
#   };
#
# Note: Configuration is applied via `rustdesk --config` on first login.
#       The password is set via `rustdesk --password`.

{ pkgs, lib, config, userConfig, ... }:

let
  hasRustdeskConfig = userConfig ? rustdesk;
  hasServer = hasRustdeskConfig && userConfig.rustdesk ? server;
  hasKey = hasRustdeskConfig && userConfig.rustdesk ? key;
  hasPassword = hasRustdeskConfig && userConfig.rustdesk ? password;

  # Build the RustDesk --config string
  # Format: "host=server.example.com,key=PUBLICKEY"
  # Reference: https://github.com/rustdesk/rustdesk/discussions/7118
  configParts = lib.optional hasServer "host=${userConfig.rustdesk.server}"
    ++ lib.optional hasKey "key=${userConfig.rustdesk.key}";
  configString = lib.concatStringsSep "," configParts;

  # Flatpak RustDesk binary path
  flatpakRustdesk = "/var/lib/flatpak/exports/bin/com.rustdesk.RustDesk";
in
{
  # Configure RustDesk server settings via systemd user service
  # Uses --config command line option which requires the app to be installed
  systemd.user.services = lib.mkMerge [
    # Service to configure server/key
    (lib.mkIf (hasServer || hasKey) {
      rustdesk-configure = {
        Unit = {
          Description = "Configure RustDesk server settings";
          After = [ "graphical-session.target" ];
        };
        Service = {
          Type = "oneshot";
          ExecStart = toString (pkgs.writeShellScript "rustdesk-configure" ''
            CONFIG_STRING="${configString}"
            
            # Mark file to track if config has been applied
            CONFIG_MARKER="$HOME/.config/rustdesk/.nix-configured"
            
            # Only configure if not already done (or config changed)
            if [ -f "$CONFIG_MARKER" ] && [ "$(cat "$CONFIG_MARKER")" = "$CONFIG_STRING" ]; then
              echo "RustDesk already configured with current settings"
              exit 0
            fi
            
            echo "Configuring RustDesk with: $CONFIG_STRING"
            
            if [ -x "${flatpakRustdesk}" ]; then
              # Flatpak needs to run with flatpak-spawn or directly
              ${flatpakRustdesk} --config "$CONFIG_STRING" || true
            elif command -v rustdesk &> /dev/null; then
              rustdesk --config "$CONFIG_STRING" || true
            else
              echo "RustDesk not found, skipping configuration"
              exit 0
            fi
            
            # Mark as configured
            mkdir -p "$(dirname "$CONFIG_MARKER")"
            echo "$CONFIG_STRING" > "$CONFIG_MARKER"
          '');
          RemainAfterExit = true;
        };
        Install = {
          WantedBy = [ "graphical-session.target" ];
        };
      };
    })

    # Service to set permanent password
    (lib.mkIf hasPassword {
      rustdesk-set-password = {
        Unit = {
          Description = "Set RustDesk permanent password";
          After = [ "graphical-session.target" "rustdesk-configure.service" ];
        };
        Service = {
          Type = "oneshot";
          ExecStart = toString (pkgs.writeShellScript "rustdesk-set-password" ''
            if [ -x "${flatpakRustdesk}" ]; then
              ${flatpakRustdesk} --password "${userConfig.rustdesk.password}"
            elif command -v rustdesk &> /dev/null; then
              rustdesk --password "${userConfig.rustdesk.password}"
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
    })
  ];
}
