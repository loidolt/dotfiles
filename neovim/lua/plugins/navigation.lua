-- Code Navigation & Understanding Plugins
-- Better ways to navigate and understand your code

return {
  -- Trouble: Better diagnostics list
  -- Pretty list of LSP diagnostics, references, etc.
  -- <leader>xx to toggle
  {
    'folke/trouble.nvim',
    cmd = { 'Trouble' },
    opts = { use_diagnostic_signs = true },
    keys = {
      { '<leader>xx', '<cmd>Trouble diagnostics toggle<cr>', desc = 'Diagnostics (Trouble)' },
      { '<leader>xX', '<cmd>Trouble diagnostics toggle filter.buf=0<cr>', desc = 'Buffer Diagnostics (Trouble)' },
      { '<leader>cs', '<cmd>Trouble symbols toggle focus=false<cr>', desc = 'Symbols (Trouble)' },
      { '<leader>cl', '<cmd>Trouble lsp toggle focus=false win.position=right<cr>', desc = 'LSP Definitions / references / ... (Trouble)' },
      { '<leader>xL', '<cmd>Trouble loclist toggle<cr>', desc = 'Location List (Trouble)' },
      { '<leader>xQ', '<cmd>Trouble qflist toggle<cr>', desc = 'Quickfix List (Trouble)' },
    },
  },

  -- Symbols Outline: Code structure sidebar
  -- Shows functions, classes, variables in a tree
  -- <leader>co to toggle
  {
    'hedyhli/outline.nvim',
    cmd = { 'Outline', 'OutlineOpen' },
    keys = {
      { '<leader>co', '<cmd>Outline<CR>', desc = 'Toggle outline' },
    },
    opts = {
      outline_window = {
        position = 'right',
        width = 25,
        relative_width = true,
      },
      symbols = {
        icon_source = 'lspkind',
      },
    },
  },

  -- LSP Lines: Show diagnostics inline
  -- Better visualization of diagnostics
  -- <leader>tl to toggle
  {
    'https://git.sr.ht/~whynothugo/lsp_lines.nvim',
    event = 'LspAttach',
    config = function()
      require('lsp_lines').setup()
      -- Disable virtual_text since lsp_lines is more readable
      vim.diagnostic.config { virtual_text = false }
    end,
    keys = {
      {
        '<leader>tl',
        function()
          local new_value = not vim.diagnostic.config().virtual_lines
          vim.diagnostic.config { virtual_lines = new_value, virtual_text = not new_value }
        end,
        desc = 'Toggle lsp_lines',
      },
    },
  },
}
