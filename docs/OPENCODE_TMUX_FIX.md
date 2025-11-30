# OpenCode Theme Fix for Tmux Sessions

## Problem

OpenCode theme customizations (specifically the Catppuccin theme) were not displaying correctly when OpenCode was used inside a tmux session. The theme would appear with incorrect colors or fall back to default colors.

## Root Cause

Tmux needs explicit configuration to support 24-bit truecolor, which is required for OpenCode themes to display properly. Without this configuration:

- Tmux defaults to 256-color mode
- OpenCode themes can't render their full color palette
- Visual customizations don't work as intended

## Solution

We've added a tmux configuration file (`.tmux.conf`) that enables truecolor support through terminal overrides.

### What Was Added

1. **Tmux Configuration** (`tmux/.tmux.conf`):
   - Enables 24-bit truecolor with `terminal-overrides`
   - Sets proper terminal type (`tmux-256color`)
   - Adds focus events and other modern terminal features
   - Includes quality-of-life improvements for terminal usage

2. **Documentation**:
   - Added `tmux/README.md` with detailed configuration explanation
   - Included troubleshooting steps and testing procedures

## How to Apply the Fix

### Option 1: Restart Your Tmux Session (Recommended)

For the changes to fully take effect, kill and restart your tmux session:

```bash
# Kill all tmux sessions
tmux kill-server

# Start a new tmux session
tmux

# Or start a named session
tmux new -s mysession
```

### Option 2: Reload Configuration (Partial Fix)

You can reload the configuration without restarting:

```bash
# Reload tmux config
tmux source ~/.tmux.conf

# Create a new pane or window for changes to take full effect
# Ctrl+b c (new window)
# or
# Ctrl+b % (new pane)
```

Note: Some changes require a full restart to take effect in existing panes.

## Verification

After applying the fix, verify truecolor is working:

### 1. Check Terminal Settings

```bash
# Should output: tmux-256color
echo $TERM

# Should output: truecolor
echo $COLORTERM

# Should show terminal overrides with Tc and RGB
tmux show-options -g -s | grep terminal
```

### 2. Test Truecolor Rendering

Run this command to see a color gradient:

```bash
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

You should see a smooth color gradient.

### 3. Test OpenCode Theme

Launch OpenCode in your tmux session:

```bash
cd /path/to/your/project
opencode
```

The Catppuccin theme should now display with its correct colors.

## Technical Details

### Terminal Overrides Explained

The key configuration lines are:

```bash
set -g default-terminal "tmux-256color"
set -as terminal-overrides ",*256col*:Tc"
set -as terminal-overrides ",*256col*:RGB"
```

- `default-terminal "tmux-256color"` - Sets the terminal type tmux reports
- `*256col*:Tc` - Enables truecolor capability for 256-color terminals
- `*256col*:RGB` - Adds RGB color support

These tell tmux to pass through 24-bit color codes to the underlying terminal emulator.

### Why This Matters for OpenCode

OpenCode themes like Catppuccin use specific RGB color values:

```json
{
  "theme": "catppuccin",
  "colors": {
    "rosewater": "#f5e0dc",
    "flamingo": "#f2cdcd",
    "pink": "#f5c2e7",
    // ... many more precise colors
  }
}
```

Without truecolor support, these get approximated to the nearest 256-color value, which can look quite different.

## Troubleshooting

### Colors still look wrong

1. **Ensure you fully restarted tmux** - Configuration changes need a fresh tmux server
2. **Check your terminal emulator** - Verify your terminal (WezTerm, Ghostty, etc.) supports 24-bit color
3. **Test outside tmux first** - Run `opencode` outside tmux to confirm the theme works
4. **Try alternative settings** - See `tmux/README.md` for alternative terminal-override configurations

### TERM variable is wrong

If `echo $TERM` doesn't show `tmux-256color`:

```bash
# Force set in your shell profile (~/.zshrc or ~/.bashrc)
if [ -n "$TMUX" ]; then
  export TERM=tmux-256color
fi
```

### Terminal emulator doesn't support truecolor

If your terminal emulator doesn't support 24-bit color, you'll need to:

1. Upgrade to a modern terminal (WezTerm, Ghostty, Alacritty, Kitty)
2. Or use a 256-color theme instead (not all OpenCode themes support this)

## Benefits Beyond OpenCode

This tmux configuration also improves:

- **Neovim/Vim** - Better color scheme support and responsiveness
- **Syntax highlighting** - More accurate colors in code editors
- **Terminal UI apps** - Better rendering for any app using truecolor
- **General terminal experience** - Focus events, mouse support, etc.

## Files Involved

- `configs/tmux/.tmux.conf` - Tmux configuration file (managed by Home Manager)
- `configs/tmux/README.md` - Documentation for tmux configuration
- `home/programs/tmux.nix` - Home Manager tmux configuration
- `docs/OPENCODE_TMUX_FIX.md` - This document

## Resources

- [OpenCode Themes Documentation](https://opencode.ai/docs/themes)
- [Tmux True Color FAQ](https://github.com/tmux/tmux/wiki/FAQ#how-do-i-use-a-256-colour-terminal)
- [Terminal Color Test Scripts](https://gist.github.com/XVilka/8346728)
- [Catppuccin Theme](https://github.com/catppuccin)
