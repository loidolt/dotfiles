# Enhanced Plugins Cheat Sheet

## Adding a Plugin

1. Edit `lua/lazyvim/plugins/extras.lua`
2. Uncomment a plugin block OR add a new one
3. Save and restart Neovim
4. Run `:Lazy sync`

Example:
```lua
{
  'github-username/plugin-name',
  opts = {},
},
```

## Common Commands

| Command | Description |
|---------|-------------|
| `:Lazy` | Open plugin manager UI |
| `:Lazy sync` | Install/update all plugins |
| `:Lazy clean` | Remove unused plugins |
| `:Lazy update` | Update plugins |
| `:Mason` | Manage LSP servers/tools |
| `:checkhealth` | Diagnose issues |

## File Locations

| What | Where |
|------|-------|
| Pre-configured plugins | `lua/lazyvim/plugins/extras.lua` |
| Add your own plugins | `lua/custom/plugins/init.lua` |
| Main config | `init.lua` |
| Kickstart plugins | `lua/kickstart/plugins/` |

## Useful Key Bindings (Default Kickstart)

| Keys | Action |
|------|--------|
| `<space>sf` | Search files |
| `<space>sg` | Live grep (search in files) |
| `<space>sh` | Search help |
| `<space>sk` | Search keymaps |
| `<space>sd` | Search diagnostics |
| `<space><space>` | Find buffers |
| `grn` | LSP: Rename symbol |
| `gra` | LSP: Code action |
| `grd` | LSP: Go to definition |
| `grr` | LSP: Find references |

## Pre-configured Plugins

Open `lua/lazyvim/plugins/extras.lua` to find and enable:

- **Neo-tree**: File explorer
- **Comment.nvim**: Better commenting
- **GitHub Copilot**: AI code completion
- **Neoscroll**: Smooth scrolling

## Adding Custom Plugins

Add to `lua/lazyvim/plugins/extras.lua`:

```lua
return {
  -- Existing plugins...
  
  -- Your new plugin
  {
    'username/plugin-name',
    dependencies = { 'required-plugin' },
    keys = {
      { '<leader>x', '<cmd>Command<cr>', desc = 'Description' },
    },
    opts = {
      option = value,
    },
  },
}
```

## Plugin Configuration Patterns

### Basic plugin
```lua
{
  'username/plugin',
  opts = {},
}
```

### Plugin with keybindings
```lua
{
  'username/plugin',
  keys = {
    { '<leader>p', '<cmd>PluginCmd<cr>', desc = 'Plugin command' },
  },
  opts = {},
}
```

### Plugin with dependencies
```lua
{
  'username/plugin',
  dependencies = {
    'dependency1',
    'dependency2',
  },
  opts = {},
}
```

### Plugin that loads on event
```lua
{
  'username/plugin',
  event = 'VeryLazy',  -- or 'InsertEnter', 'BufReadPre', etc.
  opts = {},
}
```

## Troubleshooting Quick Fixes

**Plugins not loading?**
```vim
:Lazy sync
```

**LSP not working?**
```vim
:LspInfo
:Mason
```

**Something broken?**
```vim
:checkhealth
```

**Clean slate?**
```vim
:Lazy clean
:Lazy sync
```

**Syntax error in extras.lua?**
- Check all `{` have matching `}`
- Check commas between entries
- Check quotes around strings

## More Information

- Full docs: `LAZYVIM_INTEGRATION.md`
- Quick start: `QUICKSTART.md`
- Plugin ideas: https://github.com/rockerBOO/awesome-neovim
