-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set
local set = vim.opt
local defaults = { noremap = true, silent = true }
local remap = { remap = true, silent = true }

-- Sainer defaults
map("i", "jj", "<esc>", defaults)
map("n", "<C-s>", "<cmd> w <CR>", defaults)
map("n", "Y", "yy", defaults)
map("v", "<F9>", ":sort<CR>", defaults)

-- Comments
map("n", "<C-/>", "gcc", remap)
map("n", "q", "gc", remap)
map("n", "qq", "gcc", remap)
map("v", "<C-/>", "gc", remap)
map("v", "q", "gc", remap)
