# Enhanced Plugin System

Your Kickstart.nvim configuration includes a curated collection of plugin configurations in `lua/plugins/plugins.lua`.

## What is This?

This is a **simple plugin library** that:
- ✅ Keeps your existing Kickstart.nvim configuration intact
- ✅ Provides ready-to-use plugin configurations you can enable with one uncomment
- ✅ Lets you pick and choose which plugins you want
- ✅ Maintains full control and transparency over your config

## How to Use

### Step 1: Browse Available Plugins

Open `lua/plugins/plugins.lua` to see available plugin configurations.

### Step 2: Enable or Disable a Plugin

1. Open `lua/plugins/plugins.lua`
2. Find a plugin you want to enable or disable
3. Comment or uncomment the entire plugin block
4. Restart Neovim (or run `:Lazy sync`)

### Example: Configuring Plugins

In `lua/plugins/plugins.lua`:

```lua
return {
  -- Uncomment this entire block:
  {
    'nvim-neo-tree/neo-tree.nvim',
    branch = 'v3.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-tree/nvim-web-devicons',
      'MunifTanjim/nui.nvim',
    },
    keys = {
      { '<leader>e', '<cmd>Neotree toggle<cr>', desc = 'Toggle file explorer' },
    },
    opts = {
      filesystem = {
        follow_current_file = { enabled = true },
      },
    },
  },
}
```

Then restart Neovim or run `:Lazy sync`, and use `<leader>e` to toggle the file explorer!

## File Structure

```
neovim/
├── init.lua                          # Main config (Kickstart base)
├── lua/
│   └── plugins/
│       └── plugins.lua               # All additional plugins
├── lazy-lock.json                    # Plugin version lockfile
└── README.md                         # Documentation
```

## Adding Your Own Plugins

You have two options for adding plugins:

### Option 1: Use the plugins.lua file (recommended)
Add new plugin configurations directly to `lua/plugins/plugins.lua`:

```lua
return {
  {
    'your-username/your-plugin',
    opts = {
      -- your config here
    },
  },
}
```

### Option 2: Add directly to init.lua
Add plugins directly in the `require('lazy').setup({})` block in `init.lua`.

## Plugins Included

The `plugins.lua` file includes many pre-configured plugins:

- **Neo-tree**: File explorer
- **Bufferline**: Tab-like buffer management
- **Dashboard**: Beautiful startup screen
- **Noice & Notify**: Better UI for messages
- **Trouble**: Better diagnostics list
- **Flash**: Enhanced navigation
- **Gitsigns & Diffview**: Git integration
- And many more!

All plugins are enabled by default. Comment out any you don't want.

## Finding More Plugins

- Browse [awesome-neovim](https://github.com/rockerBOO/awesome-neovim)
- Check [LazyVim plugins](https://www.lazyvim.org/plugins) for inspiration
- Search GitHub for `neovim plugin [feature]`

## Managing Plugins

After making changes:

1. **Install/update plugins**: `:Lazy sync`
2. **View plugin status**: `:Lazy`
3. **Update all plugins**: `:Lazy update`
4. **Remove unused plugins**: `:Lazy clean`
5. **Check health**: `:checkhealth`

## Troubleshooting

### Plugins not loading?

1. Make sure you uncommented the entire plugin block (including all braces)
2. Run `:Lazy sync`
3. Restart Neovim
4. Check `:Lazy` for errors

### Syntax errors?

Make sure your Lua syntax is correct:
- All opening `{` have matching closing `}`
- Commas between plugin entries
- Strings are properly quoted

### Still having issues?

1. Run `:checkhealth` to diagnose
2. Check `:messages` for error details
3. Verify the plugin block syntax matches the examples

## Removing Plugins

If you want to remove all the additional plugins:

1. Remove the import from `init.lua`:
   - Delete or comment out: `{ import = 'plugins.plugins' },`

2. Delete the plugins directory:
   ```bash
   rm -rf lua/plugins
   ```

3. Run `:Lazy clean` and restart Neovim

## Tips

1. **Start small**: Enable one plugin at a time to learn what it does
2. **Read the code**: All configurations are visible in `extras.lua`
3. **Customize**: Modify any plugin config to suit your needs
4. **Stay organized**: Keep related plugins together in `extras.lua`
5. **Document**: Add comments explaining why you enabled each plugin

## Further Reading

- [lazy.nvim Documentation](https://github.com/folke/lazy.nvim)
- [Kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim)
- [Neovim Documentation](https://neovim.io/doc/)

Enjoy your enhanced Neovim experience!
