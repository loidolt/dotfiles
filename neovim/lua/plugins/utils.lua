-- Utility Plugins
-- Simple quality of life improvements

return {
  -- Better escape: jk or kj to exit insert mode
  {
    'max397574/better-escape.nvim',
    event = 'InsertEnter',
    opts = {
      mapping = { 'jk', 'kj' },
      timeout = 200,
    },
  },

  -- Smooth Scrolling
  {
    'karb94/neoscroll.nvim',
    event = 'VeryLazy',
    opts = {
      mappings = { '<C-u>', '<C-d>', '<C-b>', '<C-f>', '<C-y>', '<C-e>', 'zt', 'zz', 'zb' },
    },
  },
}
