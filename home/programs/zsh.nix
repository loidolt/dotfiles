{ pkgs, config, lib, username, ... }:

let
  # Use the DOTFILES path from dotfiles.nix
  dotfilesPath = config.home.sessionVariables.DOTFILES;
in
{
  programs.zsh = {
    enable = true;

    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    # Shell aliases - common to all platforms
    shellAliases = {
      # Modern CLI replacements
      ls = "eza --icons";
      ll = "eza -l --icons --git";
      la = "eza -la --icons --git";
      lt = "eza --tree --icons";
      cat = "bat";

      # Git aliases
      g = "git";
      gs = "git status";
      gc = "git commit";
      gp = "git push";
      gl = "git pull";
      gd = "git diff";

      # Tmux aliases
      ta = "tmux attach";
      tl = "tmux ls";
      tn = "tmux new -s";

      # Convenience
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";

    } // lib.optionalAttrs pkgs.stdenv.isDarwin {
      # macOS-specific aliases
      # Home Manager rebuild (standalone)
      hm = "home-manager switch --flake $DOTFILES#${username}";
      hms = "home-manager switch --flake $DOTFILES#${username}";

      # Darwin rebuild (if using nix-darwin)
      drb = "darwin-rebuild switch --flake $DOTFILES#darwin-arm64";

    } // lib.optionalAttrs pkgs.stdenv.isLinux {
      # Linux-specific aliases
      # NixOS rebuild
      nrb = "sudo nixos-rebuild switch --flake $DOTFILES";
    };

    # Environment variables specific to zsh
    sessionVariables = {
      # Use eza for tree view
      TREE_CMD = "eza --tree";
    };

    # Oh My Zsh configuration
    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "docker"
        "kubectl"
        "npm"
        "node"
        "sudo"
        "history"
        "colored-man-pages"
      ];
      theme = ""; # We use starship instead
    };

    # Additional initialization
    initContent = ''
      # Initialize zoxide (smart cd)
      eval "$(zoxide init zsh)"

      # Better history
      setopt HIST_IGNORE_ALL_DUPS
      setopt HIST_FIND_NO_DUPS
      setopt HIST_SAVE_NO_DUPS

      # Case-insensitive completion
      zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

      # Vi mode
      bindkey -v
      bindkey '^R' history-incremental-search-backward
    '';
  };
}
