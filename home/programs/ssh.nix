# SSH Configuration
# Manages SSH client settings and ssh-agent with security best practices
#
# Host-specific configurations (work servers, internal networks, etc.)
# should be defined in ssh-hosts.nix which is gitignored.
# See ssh-hosts.nix.example for a template.

{ pkgs, lib, dotfilesPath, ... }:

let
  # Check if the hosts file exists and import it
  hostsFile = dotfilesPath + "/home/programs/ssh-hosts.nix";
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

    # Global SSH client configuration
    extraConfig = ''
      # Security defaults
      Protocol 2
      HashKnownHosts yes
      VisualHostKey yes
      
      # Connection settings
      TCPKeepAlive yes
      ServerAliveInterval 60
      ServerAliveCountMax 3
      
      # Key management
      IdentitiesOnly yes
      PasswordAuthentication no
      ChallengeResponseAuthentication no
      
      # Prefer modern algorithms
      PubkeyAcceptedKeyTypes ssh-ed25519,ecdsa-sha2-nistp256,ecdsa-sha2-nistp384,ecdsa-sha2-nistp521,rsa-sha2-512,rsa-sha2-256
      HostKeyAlgorithms ssh-ed25519,ecdsa-sha2-nistp256,ecdsa-sha2-nistp384,ecdsa-sha2-nistp521,rsa-sha2-512,rsa-sha2-256
      KexAlgorithms curve25519-sha256@libssh.org,diffie-hellman-group16-sha512,diffie-hellman-group18-sha512
      Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr
      MACs hmac-sha2-256-etm@openssh.com,hmac-sha2-512-etm@openssh.com,umac-128-etm@openssh.com
    '';

    matchBlocks = {
      # Default settings for all hosts
      "*" = {
        addKeysToAgent = "yes";
        extraOptions = lib.optionalAttrs pkgs.stdenv.isDarwin {
          UseKeychain = "yes";
        } // {
          # Connection multiplexing for better performance
          ControlMaster = "auto";
          ControlPath = "~/.ssh/master-%r@%h:%p";
          ControlPersist = "10m";
        };
      };

      # GitHub - this is public information, safe to include
      "github.com" = {
        hostname = "github.com";
        user = "git";
        identityFile = "~/.ssh/id_ed25519_github";
        # GitHub-specific optimizations
        extraOptions = {
          MACs = "hmac-sha2-256-etm@openssh.com,hmac-sha2-512-etm@openssh.com,hmac-sha2-256,hmac-sha2-512";
          Compression = "yes";
        };
      };
      
      # GitLab (in case you use it)
      "gitlab.com" = {
        hostname = "gitlab.com";
        user = "git";
        identityFile = "~/.ssh/id_ed25519_github"; # Can use same key or separate one
        extraOptions = {
          MACs = "hmac-sha2-256-etm@openssh.com,hmac-sha2-512-etm@openssh.com,hmac-sha2-256,hmac-sha2-512";
          Compression = "yes";
        };
      };
    } // (hostConfig.matchBlocks or {});
  };

  # Enable ssh-agent via home-manager on Linux only
  # On macOS, the system ssh-agent is used instead
  services.ssh-agent.enable = !pkgs.stdenv.isDarwin;
}
