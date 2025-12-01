{
  description = "Cross-platform NixOS/macOS/WSL dotfiles";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, nix-darwin, nixos-wsl, ... }@inputs:
    let
      username = "chrisloidolt";
      vmUsername = "loidolt";
      
      # Supported systems
      systems = [
        "aarch64-darwin"  # Apple Silicon
        "x86_64-darwin"   # Intel Mac
        "aarch64-linux"   # ARM64 Linux
        "x86_64-linux"    # x86_64 Linux
      ];
      
      # Helper to generate package sets for all systems
      forAllSystems = nixpkgs.lib.genAttrs systems;
      
      # Helper function for system-specific package sets
      mkPkgs = system: import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    in
    {
      # Development shells for all systems
      devShells = forAllSystems (system: {
        default = (mkPkgs system).mkShell {
          buildInputs = with (mkPkgs system); [
            nil           # Nix LSP
            nixpkgs-fmt   # Nix formatter
            statix        # Nix linter
          ];
        };
      });
      
      # Formatter for all systems
      formatter = forAllSystems (system: (mkPkgs system).nixpkgs-fmt);
      
      # Home Manager standalone (for existing macOS setup - keep for backward compatibility)
      homeConfigurations = {
        "${username}" = home-manager.lib.homeManagerConfiguration {
          pkgs = mkPkgs "aarch64-darwin";
          extraSpecialArgs = { inherit inputs username; };
          modules = [ ./home ];
        };
        
        # Add x86_64 macOS support
        "${username}-x86" = home-manager.lib.homeManagerConfiguration {
          pkgs = mkPkgs "x86_64-darwin";
          extraSpecialArgs = { inherit inputs username; };
          modules = [ ./home ];
        };
      };
      
      # Darwin configurations (macOS with nix-darwin)
      darwinConfigurations = {
        # ARM64 Mac (Apple Silicon)
        "darwin-arm64" = nix-darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          specialArgs = { inherit inputs username; };
          modules = [
            ./hosts/darwin
            home-manager.darwinModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users.${username} = import ./home;
                extraSpecialArgs = { inherit inputs username; };
              };
            }
          ];
        };
        
        # Intel Mac (optional - for x86_64 Macs)
        "darwin-x86" = nix-darwin.lib.darwinSystem {
          system = "x86_64-darwin";
          specialArgs = { inherit inputs username; };
          modules = [
            ./hosts/darwin
            home-manager.darwinModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users.${username} = import ./home;
                extraSpecialArgs = { inherit inputs username; };
              };
            }
          ];
        };
      };
      
      # NixOS configurations
      nixosConfigurations = {
        # NixOS VM (Parallels ARM64)
        nixos-desktop = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          specialArgs = { 
            inherit inputs;
            username = vmUsername;
          };
          modules = [
            ./hosts/nixos-desktop
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.${vmUsername} = import ./home;
              home-manager.extraSpecialArgs = { 
                inherit inputs;
                username = vmUsername;
              };
            }
          ];
        };
        
        # WSL2 configuration (typically x86_64)
        wsl = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { 
            inherit inputs;
            username = username;
          };
          modules = [
            nixos-wsl.nixosModules.wsl
            ./hosts/wsl
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.${username} = import ./home;
              home-manager.extraSpecialArgs = { 
                inherit inputs;
                username = username;
              };
            }
          ];
        };
      };
    };
}
