return {
  lazy = false,
  "aaronlord/tdd.nvim",
  config = function()
    vim.keymap.set("n", "<leader>tj", function()
      require("tdd").jump()
    end, { desc = "Jump between tests and the sut" })
  end,
}
