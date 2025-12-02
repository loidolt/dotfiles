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

      # Helper to create a Home Manager configuration
      mkHome = system: home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
        extraSpecialArgs = {
          inherit userConfig;
          username = userConfig.username;
        };
        modules = [ ./home ];
      };

      # Supported systems for dev shells
      systems = [ "aarch64-darwin" "x86_64-darwin" "x86_64-linux" "aarch64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
      mkPkgs = system: import nixpkgs { inherit system; };

    in {
      # Home Manager configurations
      homeConfigurations = {
        # macOS (Apple Silicon) - primary
        "${userConfig.username}" = mkHome "aarch64-darwin";
        
        # macOS (Intel)
        "${userConfig.username}-x86" = mkHome "x86_64-darwin";
        
        # Linux (x86_64) - works on native Linux and WSL2
        "${userConfig.username}-linux" = mkHome "x86_64-linux";
        
        # Linux (ARM64)
        "${userConfig.username}-arm" = mkHome "aarch64-linux";
      };

      # Development shell for working on this repo
      devShells = forAllSystems (system: {
        default = (mkPkgs system).mkShell {
          buildInputs = with (mkPkgs system); [ nil nixpkgs-fmt statix ];
        };
      });

      # Formatter
      formatter = forAllSystems (system: (mkPkgs system).nixpkgs-fmt);
    };
}
