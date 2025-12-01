{ config, pkgs, lib, username, ... }:

{
  # Set the primary user for per-user settings
  system.primaryUser = username;

  # Nix configuration
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      
      # Binary caches
      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
      
      # Build settings
      max-jobs = "auto";
      cores = 0;
    };
    
    # Automatic store optimization (replaces auto-optimise-store)
    optimise.automatic = true;
    
    # Garbage collection
    gc = {
      automatic = true;
      interval = { Weekday = 0; Hour = 0; Minute = 0; };
      options = "--delete-older-than 30d";
    };
  };

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

  # Fonts (using modern nerd-fonts syntax)
  fonts = {
    packages = with pkgs; [
      nerd-fonts.fira-code
      nerd-fonts.jetbrains-mono
      nerd-fonts.meslo-lg
    ];
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

  # Enable Touch ID for sudo (updated option name)
  security.pam.services.sudo_local.touchIdAuth = true;
}
