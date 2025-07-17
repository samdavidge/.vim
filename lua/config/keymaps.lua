-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Leader \  [Toggle explorer]
vim.keymap.set("n", "<Leader>\\", function()
  Snacks.explorer()
end, { silent = true })

-- alt + Right [Next Buffer]
vim.keymap.set("n", "<A-Right>", ":bnext<Cr>", { silent = true })
vim.keymap.set("n", "<A-Left>", ":bprev<Cr>", { silent = true })

-- ctrl + c [Close current buffer]
vim.keymap.set("n", "<C-c>", ":BufferClose<Cr>", { silent = true })

vim.keymap.set("n", "<Leader>bo", ":BufferOrderByBufferNumber<Cr>", { silent = true })
vim.keymap.set("n", "<Leader>bc", "::BufferCloseAllButPinned<Cr>", { silent = true })

-- codecompanion
vim.keymap.set("n", "<Leader>ai", function()
  require("codecompanion").toggle()
end, { silent = true })

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
