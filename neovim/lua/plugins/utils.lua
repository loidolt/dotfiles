-- Utility Plugins
-- Quality of life improvements and helpful utilities

return {
  -- Persistence: Session management
  -- Automatically saves and restores sessions
  {
    'folke/persistence.nvim',
    event = 'BufReadPre',
    opts = { options = vim.opt.sessionoptions:get() },
    keys = {
      { '<leader>qs', function() require('persistence').load() end, desc = 'Restore Session' },
      { '<leader>ql', function() require('persistence').load { last = true } end, desc = 'Restore Last Session' },
      { '<leader>qd', function() require('persistence').stop() end, desc = "Don't Save Current Session" },
    },
  },

  -- Better escape
  -- jk or kj to exit insert mode
  {
    'max397574/better-escape.nvim',
    event = 'InsertEnter',
    opts = {
      mapping = { 'jk', 'kj' },
      timeout = 200,
    },
  },

  -- Dressing: Better UI for input and select
  {
    'stevearc/dressing.nvim',
    lazy = true,
    init = function()
      vim.ui.select = function(...)
        require('lazy').load { plugins = { 'dressing.nvim' } }
        return vim.ui.select(...)
      end
      vim.ui.input = function(...)
        require('lazy').load { plugins = { 'dressing.nvim' } }
        return vim.ui.input(...)
      end
    end,
  },

  -- Smooth Scrolling
  {
    'karb94/neoscroll.nvim',
    event = 'VeryLazy',
    opts = {
      mappings = { '<C-u>', '<C-d>', '<C-b>', '<C-f>', '<C-y>', '<C-e>', 'zt', 'zz', 'zb' },
    },
  },

  -- OPTIONAL: GitHub Copilot
  -- Uncomment to enable AI-powered completions
  -- {
  --   'github/copilot.vim',
  --   event = 'InsertEnter',
  -- },
}
