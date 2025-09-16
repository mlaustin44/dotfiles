vim.g.mapleader = " "
local keymap = vim.keymap

-- Better window navigation
keymap.set("n", "<C-h>", "<C-w>h")
keymap.set("n", "<C-j>", "<C-w>j")
keymap.set("n", "<C-k>", "<C-w>k")
keymap.set("n", "<C-l>", "<C-w>l")

-- Clear search highlight
keymap.set("n", "<Esc>", ":nohl<CR>")

-- Better indenting
keymap.set("v", "<", "<gv")
keymap.set("v", ">", ">gv")

-- Move lines
keymap.set("v", "J", ":m '>+1<CR>gv=gv")
keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- Keep cursor centered
keymap.set("n", "<C-d>", "<C-d>zz")
keymap.set("n", "<C-u>", "<C-u>zz")
keymap.set("n", "n", "nzzzv")
keymap.set("n", "N", "Nzzzv")

-- remap delete to not override clipboard
keymap.set({"n", "v"}, "d", '"_d')
keymap.set({"n", "v"}, "D", '"_D')
keymap.set({"n", "v"}, "c", '"_c')
keymap.set({"n", "v"}, "C", '"_C')
keymap.set("n", "x", '"_x')

-- keymap.set('v', '<C-S-c>', '"+y')
