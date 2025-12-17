{
  description = "Cross-platform dotfiles with Home Manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }:
    let
      # Import user configuration
      userConfig = import ./user.nix;
      
      # Self-locating dotfiles path
      dotfilesPath = toString ./.;

      # Helper to create a Home Manager configuration
      mkHome = system: home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
        extraSpecialArgs = {
          inherit userConfig dotfilesPath;
        };
        modules = [ ./home ];
      };

      # Supported systems
      systems = [ "aarch64-darwin" "x86_64-darwin" "x86_64-linux" "aarch64-linux" ];

    in {
      # Home Manager configurations
      homeConfigurations = {
        # Auto-detect current platform (default)
        default = mkHome builtins.currentSystem;
        
        # Optional: Explicit platform targeting (rarely needed)
        # Usage: home-manager switch --flake .#aarch64-darwin
      } // (builtins.listToAttrs (map (system: {
        name = system;
        value = mkHome system;
      }) systems));

      # Packages for home-manager to use
      packages = builtins.listToAttrs (map (system: {
        name = system;
        value = {
          # Provide the activation package for home-manager
          homeConfigurations."chrisloidolt" = mkHome system;
        };
      }) systems);
    };
}
