# SSH Configuration
# Manages SSH client settings and ssh-agent across all hosts

{ pkgs, lib, ... }:

{
  programs.ssh = {
    enable = true;

    # Disable default config - we explicitly set what we need in matchBlocks."*"
    # This silences the deprecation warning about future removal of defaults
    enableDefaultConfig = false;

    # GitHub configuration
    matchBlocks = {
      # Default settings for all hosts
      "*" = {
        addKeysToAgent = "yes";
        # Explicit defaults we want to keep (previously set by enableDefaultConfig)
        extraOptions = {
          IdentitiesOnly = "no";
        };
      };

      "github.com" = {
        hostname = "github.com";
        user = "git";
        identityFile = "~/.ssh/id_ed25519_github";
        addKeysToAgent = "yes";
      };
    };

    # Extra config for macOS
    extraConfig = lib.optionalString pkgs.stdenv.isDarwin ''
      # Use macOS Keychain
      UseKeychain yes
    '';
  };

  # Enable ssh-agent via home-manager
  services.ssh-agent.enable = !pkgs.stdenv.isDarwin;
  # Note: On macOS, the system ssh-agent is used instead
}
