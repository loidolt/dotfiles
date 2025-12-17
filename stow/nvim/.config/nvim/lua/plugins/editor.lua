-- Editor Enhancement Plugins
-- Basic editing improvements for a better text editing experience

return {
  -- Auto Pairs: Automatically close brackets, quotes, etc.
  {
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    config = true,
    opts = {
      fast_wrap = {},
      disable_filetype = { 'TelescopePrompt', 'vim' },
    },
  },

  -- Better Comments: Easy comment toggling
  -- gcc to comment a line, gc in visual mode
  {
    'numToStr/Comment.nvim',
    event = 'VeryLazy',
    opts = {},
  },

  -- Indent Guides: Visual indent lines
  {
    'lukas-reineke/indent-blankline.nvim',
    event = { 'BufReadPost', 'BufNewFile' },
    main = 'ibl',
    opts = {
      indent = {
        char = '│',
        tab_char = '│',
      },
      scope = { enabled = false },
      exclude = {
        filetypes = {
          'help',
          'lazy',
          'mason',
          'notify',
        },
      },
    },
  },
}
