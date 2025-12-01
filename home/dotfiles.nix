{ config, pkgs, ... }:

{
  home.sessionVariables = {
    # Dotfiles location - auto-detect based on platform
    DOTFILES = 
      if pkgs.stdenv.isDarwin 
      then "${config.home.homeDirectory}/Documents/GitHub/dotfiles"
      else "${config.home.homeDirectory}/dotfiles";
  };
}
