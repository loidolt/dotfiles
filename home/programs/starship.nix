{ pkgs, ... }:

{
  programs.starship = {
    enable = true;
    
    settings = {
      # Prompt format
      format = "$all";
      
      # Increase command timeout to avoid warnings
      command_timeout = 1000;  # 1 second (default is 500ms)
      
      # Character configuration
      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[➜](bold red)";
        vimcmd_symbol = "[←](bold green)";
      };
      
      # Git branch
      git_branch = {
        symbol = " ";
        format = "on [$symbol$branch(:$remote_branch)]($style) ";
      };
      
      # Git status
      git_status = {
        format = "([$all_status$ahead_behind]($style) )";
        conflicted = "🏳";
        ahead = "⇡\${count}";
        behind = "⇣\${count}";
        diverged = "⇕⇡\${ahead_count}⇣\${behind_count}";
        untracked = "?";
        stashed = "$";
        modified = "!";
        staged = "+";
        renamed = "»";
        deleted = "✘";
      };
      
      # Programming languages
      nodejs = {
        symbol = " ";
        format = "via [$symbol($version )]($style)";
      };
      
      python = {
        symbol = " ";
        format = "via [$symbol($version )]($style)";
      };
      
      rust = {
        symbol = " ";
        format = "via [$symbol($version )]($style)";
      };
      
      # Bun - disable to avoid timeout warnings
      bun = {
        disabled = true;
      };
      
      # Docker
      docker_context = {
        symbol = " ";
        format = "via [$symbol$context]($style) ";
      };
      
      # Directory
      directory = {
        truncation_length = 3;
        truncate_to_repo = true;
        style = "bold cyan";
      };
      
      # Command duration
      cmd_duration = {
        min_time = 500;
        format = "took [$duration]($style) ";
      };
      
      # Time
      time = {
        disabled = true;
        format = "at 🕙 [$time]($style) ";
        time_format = "%T";
      };
    };
  };
}
