{ pkgs, ... }:

{
  programs.tmux = {
    enable = true;
    
    # Use tmux 3.x+
    terminal = "tmux-256color";
    
    # Enable mouse support
    mouse = true;
    
    # Start window and pane numbering at 1
    baseIndex = 1;
    
    # Use vi mode
    keyMode = "vi";
    
    # Set escape time to 0 for better vim/neovim experience
    escapeTime = 0;
    
    # Increase scrollback buffer
    historyLimit = 50000;
    
    # Automatically renumber windows
    extraConfig = ''
      # Enable 24-bit truecolor support
      set -as terminal-overrides ",*256col*:Tc"
      set -as terminal-overrides ",*256col*:RGB"
      
      # Enable focus events (useful for editors)
      set -g focus-events on
      
      # Start pane indices at 1
      setw -g pane-base-index 1
      
      # Renumber windows when one is closed
      set -g renumber-windows on
      
      # Enable activity monitoring
      setw -g monitor-activity on
      set -g visual-activity off
      
      # Set terminal title
      set -g set-titles on
      set -g set-titles-string "#T"
      
      # Status bar configuration
      set -g status-interval 5
      set -g status-position bottom
      set -g status-justify left
      
      # Allow automatic renaming of windows
      setw -g automatic-rename on
      
      # Better split bindings (use current path)
      bind '"' split-window -c "#{pane_current_path}"
      bind % split-window -h -c "#{pane_current_path}"
      bind c new-window -c "#{pane_current_path}"
      
      # Easy config reload
      bind r source-file ~/.config/tmux/tmux.conf \; display-message "Config reloaded!"
      
      # Vi mode copy/paste
      bind-key -T copy-mode-vi v send-keys -X begin-selection
      bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel
    '';
  };
}
