{ pkgs, ... }:

{
  programs.fzf = {
    enable = true;
    
    # Use fd instead of find for better performance and respects .gitignore
    defaultCommand = "fd --type f --hidden --follow --exclude .git";
    
    # FZF options
    defaultOptions = [
      "--height 40%"
      "--layout=reverse"
      "--border"
      "--inline-info"
      "--preview 'bat --color=always --style=numbers --line-range=:500 {}'"
    ];
    
    # Enable shell integration
    enableZshIntegration = true;
    
    # File search
    fileWidgetCommand = "fd --type f --hidden --follow --exclude .git";
    fileWidgetOptions = [
      "--preview 'bat --color=always --style=numbers --line-range=:500 {}'"
    ];
    
    # Directory search
    changeDirWidgetCommand = "fd --type d --hidden --follow --exclude .git";
    changeDirWidgetOptions = [
      "--preview 'eza --tree --color=always {} | head -200'"
    ];
  };
}
