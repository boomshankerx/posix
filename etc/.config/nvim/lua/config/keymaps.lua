-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set
local set = vim.opt
local noremap = { noremap = true, silent = true }
local remap = { remap = true, silent = true }

-- Sainer defaults
--map("n", "Y", "yy", noremap)
map("i", "jj", "<esc>", noremap)
map("n", "<C-s>", "<cmd> w <CR>", noremap)
map("n", "VC", "ggVGy", noremap)
map("n", "VV", "ggVG", noremap)
map("v", "<F9>", ":sort<CR>", noremap)

-- Comments
map("n", "<C-/>", "gcc", remap)
map("n", "<C-_>", "gcc", remap)
map("n", "q", "gc", remap)
map("n", "qq", "gcc", remap)
map("v", "<C-/>", "gc", remap)
map("v", "q", "gc", remap)
