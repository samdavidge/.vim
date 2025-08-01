return {
  lazy = false,
  "aaronlord/pest.nvim",
  config = function()
    vim.keymap.set("n", "<leader>tj", function()
      require("pest").jump()
    end, { desc = "Jump between tests and the sut" })
  end,
}
