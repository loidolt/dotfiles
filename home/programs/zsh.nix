{ pkgs, config, lib, username, ... }:

let
  # Use the DOTFILES path from dotfiles.nix
  dotfilesPath = config.home.sessionVariables.DOTFILES;
  
  # Script to set zsh as default shell if it isn't already
  set-zsh-default = pkgs.writeShellScriptBin "set-zsh-default" ''
    ZSH_PATH="${pkgs.zsh}/bin/zsh"
    
    # Check if zsh is already the default shell
    if [ "$SHELL" = "$ZSH_PATH" ]; then
      exit 0
    fi
    
    echo "Setting zsh as default shell..."
    
    # Add zsh to /etc/shells if not present (requires sudo)
    if ! grep -q "$ZSH_PATH" /etc/shells 2>/dev/null; then
      echo "Adding $ZSH_PATH to /etc/shells (requires sudo)..."
      echo "$ZSH_PATH" | sudo tee -a /etc/shells > /dev/null
    fi
    
    # Change the default shell
    echo "Changing default shell to zsh (requires sudo)..."
    sudo chsh -s "$ZSH_PATH" "$USER"
    
    echo "Default shell changed to zsh. Please log out and back in for the change to take effect."
  '';
in
{
  # Add the helper script to packages
  home.packages = [ set-zsh-default ];

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

      # Dotfiles management
      dotfiles-check = "cd $DOTFILES && nix flake check && echo 'All checks passed!'";
      hm-update = "$DOTFILES/scripts/update.sh";
      hm-validate = "$DOTFILES/scripts/validate-nix.sh";

    } // lib.optionalAttrs pkgs.stdenv.isDarwin {
      # macOS rebuild alias (--impure allows reading gitignored ssh-hosts.nix)
      hm = "home-manager switch --flake $DOTFILES#${username} --impure";

    } // lib.optionalAttrs pkgs.stdenv.isLinux {
      # Linux rebuild alias (--impure allows reading gitignored ssh-hosts.nix)
      hm = "home-manager switch --flake $DOTFILES#${username}-linux --impure";
    };

    # Environment variables specific to zsh
    sessionVariables = {
      # Use eza for tree view
      TREE_CMD = "eza --tree";
      # Add local bin directories to PATH (for tools like Claude Code, OpenCode, etc.)
      PATH = "$HOME/.local/bin:$HOME/.opencode/bin:$PATH";
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
