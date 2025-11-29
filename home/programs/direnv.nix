{ pkgs, ... }:

{
  programs.direnv = {
    enable = true;
    
    # Enable nix-direnv for better performance with Nix projects
    nix-direnv.enable = true;
    
    # Enable shell integration
    enableZshIntegration = true;
    
    # Silence direnv output (less spam)
    config = {
      global = {
        hide_env_diff = true;
      };
    };
  };
}
