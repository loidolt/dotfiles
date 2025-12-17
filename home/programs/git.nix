{ pkgs, lib, userConfig, ... }:

{
  programs.git = {
    enable = true;

    # Git settings using the new format
    settings = {
      # User info from user.nix
      user = {
        name = lib.mkDefault userConfig.git.name;
        email = lib.mkDefault userConfig.git.email;
      };

      init.defaultBranch = "main";

      core = {
        editor = "nvim";
        autocrlf = "input";
      };

      pull.rebase = false;
      push.autoSetupRemote = true;

      merge.conflictstyle = "diff3";
      diff.colorMoved = "default";
      color.ui = "auto";

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
