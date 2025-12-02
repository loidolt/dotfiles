# RustDesk configuration
# Remote desktop client with optional server/key pre-configuration

{ pkgs, lib, userConfig, ... }:

let
  hasRustdeskConfig = userConfig ? rustdesk;
  hasServer = hasRustdeskConfig && userConfig.rustdesk ? server;
  hasKey = hasRustdeskConfig && userConfig.rustdesk ? key;

  # Build the RustDesk config content
  # RustDesk uses a custom format: key=value on separate lines
  configContent = lib.optionalString hasServer ''
    rendezvous_server = ${userConfig.rustdesk.server}
    custom-rendezvous-server = ${userConfig.rustdesk.server}
  '' + lib.optionalString hasKey ''
    key = ${userConfig.rustdesk.key}
  '';
in
{
  # Only create config file if server or key is configured
  xdg.configFile = lib.mkIf (hasServer || hasKey) {
    "rustdesk/RustDesk2.toml" = {
      text = configContent;
    };
  };
}
