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
      # Import user configuration
      userConfig = import ./user.nix;
      inherit (userConfig) username vmUsername timezone locale;

      # Supported systems
      systems = [
        "aarch64-darwin" # Apple Silicon
        "x86_64-darwin"  # Intel Mac
        "aarch64-linux"  # ARM64 Linux
        "x86_64-linux"   # x86_64 Linux
      ];

      # Helper to generate package sets for all systems
      forAllSystems = nixpkgs.lib.genAttrs systems;

      # Helper function for system-specific package sets
      mkPkgs = system: import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

      # ============================================================
      # Helper Functions - Reduce boilerplate for host configurations
      # ============================================================

      # Create a NixOS configuration
      mkNixosHost = {
        system,
        hostPath,
        hostUsername,
        extraModules ? [ ],
      }: nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit inputs userConfig;
          username = hostUsername;
        };
        modules = [
          hostPath
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.${hostUsername} = import ./home;
              extraSpecialArgs = {
                inherit inputs userConfig;
                username = hostUsername;
              };
            };
          }
        ] ++ extraModules;
      };

      # Create a Darwin (macOS) configuration
      mkDarwinHost = {
        system,
        hostUsername,
        extraModules ? [ ],
      }: nix-darwin.lib.darwinSystem {
        inherit system;
        specialArgs = {
          inherit inputs userConfig;
          username = hostUsername;
        };
        modules = [
          ./hosts/darwin
          home-manager.darwinModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.${hostUsername} = import ./home;
              extraSpecialArgs = {
                inherit inputs userConfig;
                username = hostUsername;
              };
            };
          }
        ] ++ extraModules;
      };

      # Create a standalone Home Manager configuration
      mkHomeConfig = {
        system,
        homeUsername,
      }: home-manager.lib.homeManagerConfiguration {
        pkgs = mkPkgs system;
        extraSpecialArgs = {
          inherit inputs userConfig;
          username = homeUsername;
        };
        modules = [ ./home ];
      };

    in
    {
      # ============================================================
      # Development Shells
      # ============================================================
      devShells = forAllSystems (system: {
        default = (mkPkgs system).mkShell {
          buildInputs = with (mkPkgs system); [
            nil         # Nix LSP
            nixpkgs-fmt # Nix formatter
            statix      # Nix linter
          ];
        };
      });

      # Formatter for all systems
      formatter = forAllSystems (system: (mkPkgs system).nixpkgs-fmt);

      # ============================================================
      # Home Manager Standalone Configurations
      # For existing macOS setups or Linux without NixOS
      # ============================================================
      homeConfigurations = {
        # ARM64 macOS (Apple Silicon)
        "${username}" = mkHomeConfig {
          system = "aarch64-darwin";
          homeUsername = username;
        };

        # x86_64 macOS (Intel)
        "${username}-x86" = mkHomeConfig {
          system = "x86_64-darwin";
          homeUsername = username;
        };
      };

      # ============================================================
      # Darwin (macOS) Configurations
      # ============================================================
      darwinConfigurations = {
        # Apple Silicon Mac
        "darwin-arm64" = mkDarwinHost {
          system = "aarch64-darwin";
          hostUsername = username;
        };

        # Intel Mac
        "darwin-x86" = mkDarwinHost {
          system = "x86_64-darwin";
          hostUsername = username;
        };
      };

      # ============================================================
      # NixOS Configurations
      #
      # Each host directory contains a hardware-configuration.nix that must
      # be generated on the target machine and committed to the repo.
      #
      # Usage: sudo nixos-rebuild switch --flake .#<config-name>
      # ============================================================
      nixosConfigurations = {
        # NixOS Desktop (ARM64) - Graphical with KDE Plasma
        # Intended for: Parallels on Apple Silicon, ARM64 bare metal
        nixos-desktop = mkNixosHost {
          system = "aarch64-linux";
          hostPath = ./hosts/nixos-desktop;
          hostUsername = vmUsername;
        };

        # NixOS Desktop (x86_64) - Graphical with KDE Plasma
        # Intended for: VMware, VirtualBox, x86_64 bare metal
        nixos-desktop-x86 = mkNixosHost {
          system = "x86_64-linux";
          hostPath = ./hosts/nixos-desktop-x86;
          hostUsername = vmUsername;
        };

        # NixOS Headless (x86_64) - Minimal server configuration
        # Intended for: Servers, VPS, headless VMs
        nixos-headless = mkNixosHost {
          system = "x86_64-linux";
          hostPath = ./hosts/nixos-headless;
          hostUsername = vmUsername;
        };

        # WSL2 Configuration (x86_64)
        # Intended for: Windows Subsystem for Linux
        wsl = mkNixosHost {
          system = "x86_64-linux";
          hostPath = ./hosts/wsl;
          hostUsername = username;
          extraModules = [ nixos-wsl.nixosModules.wsl ];
        };
      };
    };
}
