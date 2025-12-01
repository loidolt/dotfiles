# Darwin (macOS) Configuration
#
# System-level macOS configuration using nix-darwin.
# Includes system defaults, fonts, and nix settings.

{ config, pkgs, lib, username, userConfig, ... }:

{
  imports = [
    ../../modules/shared/nix-settings.nix
    ../../modules/shared/fonts.nix
  ];

  # Set the primary user for per-user settings
  system.primaryUser = username;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Create /etc/zshrc that loads the nix-darwin environment
  programs.zsh.enable = true;

  # macOS system defaults
  system = {
    # Set macOS version
    stateVersion = 5;

    defaults = {
      # Dock settings
      dock = {
        autohide = true;
        autohide-delay = 0.0;
        autohide-time-modifier = 0.2;
        show-recents = false;
        tilesize = 48;
        orientation = "bottom";
        mru-spaces = false;
      };

      # Finder settings
      finder = {
        AppleShowAllExtensions = true;
        AppleShowAllFiles = false;
        FXEnableExtensionChangeWarning = false;
        FXPreferredViewStyle = "Nlsv"; # List view
        ShowPathbar = true;
        ShowStatusBar = true;
      };

      # Trackpad settings
      trackpad = {
        Clicking = true; # Tap to click
        TrackpadRightClick = true;
        TrackpadThreeFingerDrag = false;
      };

      # NSGlobalDomain (general macOS settings)
      NSGlobalDomain = {
        AppleShowAllExtensions = true;
        AppleShowScrollBars = "Automatic";
        NSAutomaticCapitalizationEnabled = false;
        NSAutomaticDashSubstitutionEnabled = false;
        NSAutomaticPeriodSubstitutionEnabled = false;
        NSAutomaticQuoteSubstitutionEnabled = false;
        NSAutomaticSpellingCorrectionEnabled = false;
        NSNavPanelExpandedStateForSaveMode = true;
        NSNavPanelExpandedStateForSaveMode2 = true;

        # Keyboard settings
        KeyRepeat = 2;
        InitialKeyRepeat = 15;

        # Enable full keyboard access for all controls
        AppleKeyboardUIMode = 3;
      };

      # Screencapture settings
      screencapture = {
        location = "~/Pictures/Screenshots";
        type = "png";
      };
    };

    # Keyboard settings
    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToControl = true;
    };
  };

  # System packages (minimal, most should be in Home Manager)
  environment.systemPackages = with pkgs; [
    vim
    git
  ];

  # Define user
  users.users.${username} = {
    name = username;
    home = "/Users/${username}";
    shell = pkgs.zsh;
  };

  # Enable Touch ID for sudo
  security.pam.services.sudo_local.touchIdAuth = true;
}
