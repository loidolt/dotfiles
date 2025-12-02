# RustDesk configuration
# Remote desktop client with optional server/key/password pre-configuration
#
# RustDesk is installed via Flatpak (declaratively via nix-flatpak module).
# Note: The nixpkgs package has a cargo-auditable build bug, so we use Flatpak.
#
# Configuration is done via secrets.nix:
#   rustdesk = {
#     # REQUIRED: Get this by configuring one RustDesk client manually, then:
#     # Settings → Network → Export Server Config
#     # This is a base64-encoded string containing server, relay, and key info
#     configString = "your-exported-config-string";
#
#     # OPTIONAL: Permanent password for unattended access
#     password = "your-permanent-password";
#   };
#
# Note: The --config option requires an encoded config string from RustDesk,
#       NOT raw server/key values. Export from a configured client.

{ pkgs, lib, config, userConfig, ... }:

let
  hasRustdeskConfig = userConfig ? rustdesk;
  hasConfigString = hasRustdeskConfig && userConfig.rustdesk ? configString;
  hasPassword = hasRustdeskConfig && userConfig.rustdesk ? password;

  # Flatpak RustDesk binary path
  flatpakRustdesk = "/var/lib/flatpak/exports/bin/com.rustdesk.RustDesk";
in
{
  # Configure RustDesk server settings via systemd user service
  # Uses --config command line option with the exported config string
  systemd.user.services = lib.mkMerge [
    # Service to configure server using exported config string
    (lib.mkIf hasConfigString {
      rustdesk-configure = {
        Unit = {
          Description = "Configure RustDesk server settings";
          After = [ "graphical-session.target" ];
        };
        Service = {
          Type = "oneshot";
          ExecStart = toString (pkgs.writeShellScript "rustdesk-configure" ''
            CONFIG_STRING="${userConfig.rustdesk.configString}"
            
            # Mark file to track if config has been applied
            CONFIG_MARKER="$HOME/.config/rustdesk/.nix-configured"
            
            # Only configure if not already done (or config changed)
            if [ -f "$CONFIG_MARKER" ] && [ "$(cat "$CONFIG_MARKER")" = "$CONFIG_STRING" ]; then
              echo "RustDesk already configured with current settings"
              exit 0
            fi
            
            echo "Configuring RustDesk..."
            
            if [ -x "${flatpakRustdesk}" ]; then
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
          After = [ "graphical-session.target" ] 
            ++ lib.optional hasConfigString "rustdesk-configure.service";
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
