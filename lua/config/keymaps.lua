-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Leader \  [Jump to Neotree]
vim.keymap.set("n", "<Leader>\\", ":Neotree reveal<Cr>", { silent = true })

-- alt + Right [Next Buffer]
vim.keymap.set("n", "<A-Right>", ":bnext<Cr>", { silent = true })
vim.keymap.set("n", "<A-Left>", ":bprev<Cr>", { silent = true })
