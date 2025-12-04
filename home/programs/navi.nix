{ pkgs, config, ... }:

{
  programs.navi = {
    enable = true;
    enableZshIntegration = true;
    
    settings = {
      # Use fzf for the finder
      finder = {
        command = "fzf";
      };
      
      # Cheatsheet paths
      cheats = {
        paths = [
          "${config.xdg.configHome}/navi/cheats"
        ];
      };
    };
  };
}
