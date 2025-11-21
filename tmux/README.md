# Tmux Configuration

This directory contains the tmux configuration optimized for use with OpenCode and other modern terminal applications.

## Features

- **24-bit truecolor support** - Essential for OpenCode themes to display correctly
- **Focus events** - Enables better integration with editors like Neovim
- **Zero escape time** - Improves responsiveness in Vim/Neovim
- **Mouse support** - Optional mouse integration
- **Vi mode** - Vi-style key bindings in copy mode
- **Smart window management** - Windows start at 1 and automatically renumber

## Installation

The configuration will be symlinked to `~/.tmux.conf` by the install script.

## Why Truecolor is Important

OpenCode's theme system (including the Catppuccin theme) requires 24-bit truecolor support to display properly. Without this configuration, themes may:

- Display with incorrect colors
- Fall back to 256-color approximations
- Appear washed out or different from intended design

## Testing Truecolor

After installing the configuration and restarting tmux, you can test truecolor support:

```bash
# Should show a smooth color gradient
awk 'BEGIN{
    s="/\\/\\/\\/\\/\\"; s=s s s s s s s s;
    for (colnum = 0; colnum<77; colnum++) {
        r = 255-(colnum*255/76);
        g = (colnum*510/76);
        b = (colnum*255/76);
        if (g>255) g = 510-g;
        printf "\033[48;2;%d;%d;%dm", r,g,b;
        printf "\033[38;2;%d;%d;%dm", 255-r,255-g,255-b;
        printf "%s\033[0m", substr(s,colnum+1,1);
    }
    printf "\n";
}'
```

## Applying Changes

After modifying `.tmux.conf`, you can reload it without restarting tmux:

```bash
tmux source ~/.tmux.conf
```

Or kill and restart all tmux sessions:

```bash
tmux kill-server
tmux
```

## OpenCode Integration

With this configuration, OpenCode will:

- Display themes correctly with full color palette
- Respond quickly to key inputs
- Work seamlessly with terminal focus events
- Support all visual features like syntax highlighting and UI elements

## Troubleshooting

### Colors still look wrong in tmux

1. **Check TERM variable inside tmux**:
   ```bash
   echo $TERM
   # Should show: tmux-256color
   ```

2. **Check COLORTERM variable**:
   ```bash
   echo $COLORTERM
   # Should show: truecolor
   ```

3. **Verify terminal emulator support**:
   - Ensure your terminal (WezTerm, Ghostty, Alacritty, etc.) supports 24-bit color
   - Check your terminal's configuration for truecolor settings

4. **Test outside tmux first**:
   - Run OpenCode outside tmux to verify theme works
   - If it works outside tmux but not inside, the tmux config needs adjustment

### Alternative terminal-overrides

If you still have issues, try these alternative settings in `.tmux.conf`:

```bash
# For screen-256color
set -g default-terminal "screen-256color"
set -as terminal-overrides ",*:Tc"

# Or for xterm-256color
set -g default-terminal "xterm-256color"
set -as terminal-overrides ",xterm*:Tc"
```

## Resources

- [Tmux True Color Support](https://github.com/tmux/tmux/wiki/FAQ#how-do-i-use-a-256-colour-terminal)
- [OpenCode Themes Documentation](https://opencode.ai/docs/themes)
- [Terminal Color Test Scripts](https://gist.github.com/XVilka/8346728)
