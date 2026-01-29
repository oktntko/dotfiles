-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set

-- Add custom keymap to toggle Snacks Explorer
map("n", "<C-t>", function()
  require("config.myfunction").toggle_explorer()
end, { desc = "Toggle Snacks Explorer" })

-- Add custom keymap to toggle Snacks Terminal
map({ "n", "t" }, "<C-g>", function()
  Snacks.terminal()
end, { desc = "Terminal (Root Dir)" })
