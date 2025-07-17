return {
  "OXY2DEV/markview.nvim",
  lazy = false,
  opts = {
    preview = {
      filetypes = { "markdown", "codecompanion" },
      ignore_buftypes = {},
    },
  },
  -- For `nvim-treesitter` users.
  priority = 49,

  -- For blink.cmp's completion
  -- source
  -- dependencies = {
  --     "saghen/blink.cmp"
  -- },
}
