return {
  "nvim-telescope/telescope.nvim",
  tag = false,
  dependencies = {
    "nvim-telescope/telescope-live-grep-args.nvim",
  },
  keys = {
    { "<leader>/", "<cmd>lua require('telescope').extensions.live_grep_args.live_grep_args()<cr>" },
  },
}
