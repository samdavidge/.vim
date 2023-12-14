-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- ctrl + / [Jump to Neotree]
vim.keymap.set("n", "<C-_>", "<Cmd>Neotree<Cr>")

-- shift + Right [Next Buffer]
vim.keymap.set("n", "<S-Right>", ":bnext<Cr>")
vim.keymap.set("n", "<S-Left>", ":bprev<Cr>")
