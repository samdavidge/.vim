-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Leader \  [Toggle explorer]
vim.keymap.set("n", "<Leader>\\", function()
  Snacks.explorer()
end, { silent = true })

-- ctrl + c [Close current buffer]
vim.keymap.set("n", "<C-c>", ":BufferClose<Cr>", { silent = true })

vim.keymap.set("n", "<Leader>bo", ":BufferOrderByBufferNumber<Cr>", { silent = true })
vim.keymap.set("n", "<Leader>bc", "::BufferCloseAllButPinned<Cr>", { silent = true })

-- Add jumplist and quickfix to telescope
local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>j", builtin.jumplist)
vim.keymap.set("n", "<leader>q", builtin.quickfixhistory)

-- pest
vim.keymap.set("n", "<leader>tr", function()
  require("tdd").when_test(function(file)
    -- The command runs your test, then opens a shell so the popup stays open
    local cwd = vim.fn.getcwd()
    local popup_cmd = string.format(
      "tmux popup -w 100%% -h 70%% -E 'bash -c \"cd %s && sail pest %s; echo; echo Press any key to close...; read -n 1\"'",
      cwd,
      file
    )
    vim.fn.system(popup_cmd)
  end)
end, { desc = "Run a test" })

local harpoon = require("harpoon")

harpoon:setup()

vim.keymap.set("n", "<leader>a", function()
  harpoon:list():add()
end)
vim.keymap.set("n", "<C-e>", function()
  harpoon.ui:toggle_quick_menu(harpoon:list())
end)

vim.keymap.set("n", "<C-h>", function()
  harpoon:list():select(1)
end)
vim.keymap.set("n", "<C-t>", function()
  harpoon:list():select(2)
end)
vim.keymap.set("n", "<C-n>", function()
  harpoon:list():select(3)
end)
vim.keymap.set("n", "<C-s>", function()
  harpoon:list():select(4)
end)

-- Toggle previous & next buffers stored within Harpoon list
vim.keymap.set("n", "<C-S-P>", function()
  harpoon:list():prev()
end)
vim.keymap.set("n", "<C-S-N>", function()
  harpoon:list():next()
end)
