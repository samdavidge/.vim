return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    -- opts will be merged with the parent spec
    opts = {
      window = {
        mappings = {
          ["<space>"] = "none",
          ["<Left>"] = {
            "toggle_node",
            nowait = false, -- disable `nowait` if you have existing combos starting with this char that you want to use
          },
        },
      },
    },
  },
}
