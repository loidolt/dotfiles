# SSH Configuration
# Manages SSH client settings and ssh-agent
#
# Host-specific configurations (work servers, internal networks, etc.)
# should be defined in ssh-hosts.nix which is gitignored.
# See ssh-hosts.nix.example for a template.

{ pkgs, lib, config, ... }:

let
  # Check if the hosts file exists and import it
  # Use absolute path to work with --impure flag (allows reading gitignored files)
  hostsFile = /. + (builtins.getEnv "DOTFILES") + "/home/programs/ssh-hosts.nix";
  hasHostsFile = builtins.pathExists hostsFile;
  hostConfig = if hasHostsFile then import hostsFile { inherit pkgs lib; } else {};
in
{
  # Force overwrite existing SSH config (Home Manager manages this)
  home.file.".ssh/config".force = true;

  programs.ssh = {
    enable = true;

    # Disable default config - we set what we need in matchBlocks."*"
    enableDefaultConfig = false;

    matchBlocks = {
      # Default settings for all hosts
      "*" = {
        addKeysToAgent = "yes";
        extraOptions = lib.optionalAttrs pkgs.stdenv.isDarwin {
          UseKeychain = "yes";
        };
      };

      # GitHub - this is public information, safe to include
      "github.com" = {
        hostname = "github.com";
        user = "git";
        identityFile = "~/.ssh/id_rsa";
      };
    } // (hostConfig.matchBlocks or {});
  };

  # Enable ssh-agent via home-manager on Linux only
  # On macOS, the system ssh-agent is used instead
  services.ssh-agent.enable = !pkgs.stdenv.isDarwin;
}
