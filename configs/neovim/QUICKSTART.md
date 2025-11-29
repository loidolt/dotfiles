# Kickstart + Enhanced Plugins - Quick Start

Your Neovim config now includes a library of pre-configured plugins that you can enable with just one uncomment!

## 🚀 Quick Start

### 1. First Time Setup

Open Neovim and let it install all plugins:

```bash
nvim
```

Wait for the installation to complete (you'll see progress in the bottom right).

### 2. Enable Your First Plugin

Let's add a file explorer as an example:

1. Open the plugin library:
   ```bash
   nvim lua/lazyvim/plugins/extras.lua
   ```

2. Find the Neo-tree plugin block (around line 13) and uncomment it:
   
   **Before:**
   ```lua
   -- {
   --   'nvim-neo-tree/neo-tree.nvim',
   --   branch = 'v3.x',
   --   ...
   -- },
   ```
   
   **After:**
   ```lua
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
   ```

3. Save and quit (`:wq`)

4. Reopen Neovim and run:
   ```
   :Lazy sync
   ```

5. Press `<space>e` to toggle the file explorer!

### 3. Key Commands to Know

| Command | What it does |
|---------|-------------|
| `:Lazy` | Open plugin manager |
| `:Lazy sync` | Install/update plugins |
| `:Lazy clean` | Remove unused plugins |
| `:Mason` | Manage LSP servers, formatters, linters |
| `:checkhealth` | Check for issues |
| `<space>sh` | Search help docs |
| `<space>sf` | Find files |
| `<space>sg` | Live grep (search in files) |

## 📚 What's Changed?

Your config structure:

```
neovim/
├── init.lua                    # Your main config (enhanced)
├── lua/
│   ├── custom/                 # Add your own plugins here
│   ├── kickstart/              # Kickstart plugins (unchanged)
│   └── lazyvim/                # NEW: Plugin library
│       └── plugins/
│           └── extras.lua      # Pre-configured plugins here
├── LAZYVIM_INTEGRATION.md      # Full documentation
└── QUICKSTART.md               # This file
```

## 🎯 Next Steps

1. **Read the full guide**: Open `LAZYVIM_INTEGRATION.md` for detailed info
2. **Browse available plugins**: Open `lua/lazyvim/plugins/extras.lua`
3. **Enable more plugins**: Uncomment plugin blocks in `extras.lua`
4. **Add your own**: Add custom plugins to the same file

## 🛠️ Pre-configured Plugins Available

Open `lua/lazyvim/plugins/extras.lua` to find:

- **Neo-tree**: Better file explorer (`<leader>e`)
- **Comment.nvim**: Enhanced commenting
- **GitHub Copilot**: AI code suggestions
- **Neoscroll**: Smooth scrolling

All are commented out by default - just uncomment to enable!

## 💡 Adding More Plugins

Want to add a plugin not in the list? Just add it to `extras.lua`:

```lua
return {
  -- ... existing plugins ...
  
  {
    'github-username/plugin-name',
    opts = {
      -- your configuration
    },
  },
}
```

Then run `:Lazy sync` to install!

## ❓ Having Issues?

1. Run `:checkhealth` to diagnose problems
2. Check `LAZYVIM_INTEGRATION.md` for troubleshooting  
3. Make sure all plugins are installed: `:Lazy sync`
4. Check for syntax errors in `extras.lua`

Enjoy your supercharged Neovim! 🚀
