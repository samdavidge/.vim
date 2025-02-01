return {
  {
    "romgrk/barbar.nvim",
    dependencies = {
      -- "lewis6991/gitsigns.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    init = function()
      vim.g.barbar_auto_setup = false

      require("barbar").setup({
        highlight_visible = false,
        animation = false,
        tabpages = true,
        icons = {
          button = " ",
          separator = {
            left = "▊",
            right = "▊",
          },
        },
      })
    end,
    opts = {},
    version = "^1.0.0",
  },
}
