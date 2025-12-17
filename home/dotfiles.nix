{ dotfilesPath, ... }:

{
  home.sessionVariables = {
    # Dotfiles location - self-locating, works everywhere
    DOTFILES = dotfilesPath;
  };
}
