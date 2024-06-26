return {
  {
    "folke/tokyonight.nvim",
    lazy = true,
    opts = {
      style = "moon",
      setup = {
        require("tokyonight").setup({
          on_highlights = function(hl, c)
            local prompt = "#2d3149"
            hl.TelescopeNormal = {
              bg = c.bg_dark,
              fg = c.fg_dark,
            }
            hl.TelescopeBorder = {
              bg = c.bg_dark,
              fg = c.bg_dark,
            }
            hl.TelescopePromptNormal = {
              bg = prompt,
            }
            hl.TelescopePreviewTitle = {
              bg = c.bg_dark,
              fg = c.bg_dark,
            }
            hl.TelescopeResultsTitle = {
              bg = c.bg_dark,
              fg = c.bg_dark,
            }
            hl.BufferCurrentSign = {
              fg = c.magenta,
              bg = c.magenta,
            }
            hl.ColorColumn = {
              bg = c.bg_dark,
            }
          end,
        }),
      },
    },
  },
}
