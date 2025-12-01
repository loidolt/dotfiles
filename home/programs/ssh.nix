# SSH Configuration
# Manages SSH client settings and ssh-agent across all hosts

{ pkgs, lib, ... }:

{
  programs.ssh = {
    enable = true;

    # Add keys to agent automatically when used
    addKeysToAgent = "yes";

    # GitHub configuration
    matchBlocks = {
      "github.com" = {
        hostname = "github.com";
        user = "git";
        identityFile = "~/.ssh/id_ed25519_github";
      };
    };

    # Extra config for all hosts
    extraConfig = lib.optionalString pkgs.stdenv.isDarwin ''
      # Use macOS Keychain
      UseKeychain yes
    '';
  };

  # Enable ssh-agent via home-manager
  services.ssh-agent.enable = !pkgs.stdenv.isDarwin;
  # Note: On macOS, the system ssh-agent is used instead
}
