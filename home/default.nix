{ config, pkgs, lib, username, ... }:

{
  home = {
    username = username;
    homeDirectory = 
      if pkgs.stdenv.isDarwin 
      then "/Users/${username}" 
      else "/home/${username}";
    
    stateVersion = "24.05";
  };

  # Let Home Manager manage itself
  programs.home-manager.enable = true;
}
