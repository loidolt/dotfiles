{ pkgs, username, ... }:

{
  programs.git = {
    enable = true;
    
    # Use new settings format
    settings = {
      user = {
        name = "Chris Loidolt";
        email = "chrisloidolt@gmail.com";  # Update this with your actual email
      };
      
      init = {
        defaultBranch = "main";
      };
      
      core = {
        editor = "nvim";
        autocrlf = "input";
      };
      
      pull = {
        rebase = false;
      };
      
      push = {
        autoSetupRemote = true;
      };
      
      merge = {
        conflictstyle = "diff3";
      };
      
      diff = {
        colorMoved = "default";
      };
      
      color = {
        ui = "auto";
      };
      
      alias = {
        st = "status";
        ci = "commit";
        co = "checkout";
        br = "branch";
        unstage = "reset HEAD --";
        last = "log -1 HEAD";
        visual = "log --graph --oneline --all";
        amend = "commit --amend --no-edit";
      };
    };
    
    ignores = [
      ".DS_Store"
      "*.swp"
      "*.swo"
      "*~"
      ".vscode/"
      ".idea/"
      "node_modules/"
      ".env"
      ".env.local"
    ];
  };
  
  # Delta for better diffs
  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      navigate = true;
      line-numbers = true;
      syntax-theme = "Dracula";
    };
  };
  
  # GitHub CLI
  programs.gh = {
    enable = true;
    settings = {
      git_protocol = "ssh";
      prompt = "enabled";
    };
  };
}
