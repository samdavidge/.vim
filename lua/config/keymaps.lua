-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- alt + / [Jump to Neotree]
vim.keymap.set("n", "<A-/>", "<Cmd>Neotree reveal<Cr>")

-- alt + Right [Next Buffer]
vim.keymap.set("n", "<A-Right>", ":bnext<Cr>")
vim.keymap.set("n", "<A-Left>", ":bprev<Cr>")
