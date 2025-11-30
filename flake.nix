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
      
      # Note: VM uses username "loidolt" instead of "chrisloidolt"
      vmUsername = "loidolt";
    in
    {
      # Home Manager standalone (for macOS ARM)
      homeConfigurations = {
        "${username}" = home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            system = "aarch64-darwin";
            config.allowUnfree = true;
          };
          extraSpecialArgs = { inherit inputs username; };
          modules = [ ./home ];
        };
      };
      
      # NixOS configurations
      nixosConfigurations = {
        # NixOS VM (Parallels ARM64)
        nixos-desktop = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          specialArgs = { 
            inherit inputs;
            username = vmUsername;  # VM uses "loidolt" not "chrisloidolt"
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
      };
      
      # We'll add Darwin and WSL configurations later
    };
}
