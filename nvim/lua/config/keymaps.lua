-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set

-- Delete without copying to clipboard 削除時にクリップボードにコピーしない
map("n", "x", '"_x')
map("n", "X", '"_X')
map("n", "<Del>", '"_x')

-- Standard Ctrl shortcuts like other applications
-- Ctrl+C: Copy (yank)
map("n", "<C-c>", "yy", { desc = "Copy line" })
map("v", "<C-c>", "y", { desc = "Copy selection" })

-- Ctrl+X: Cut
map("n", "<C-x>", "dd", { desc = "Cut line" })
map("v", "<C-x>", "d", { desc = "Cut selection" })

-- Ctrl+V: Paste
map("n", "<C-v>", "p", { desc = "Paste after cursor" })
map({ "i", "c" }, "<C-v>", "<C-r>+", { desc = "Paste from clipboard" })

-- Ctrl+Z: Undo
map("n", "<C-z>", "u", { desc = "Undo" })
map("i", "<C-z>", "<Cmd>undo<CR>", { desc = "Undo in insert mode" })

-- Ctrl+Y: Redo
map("n", "<C-y>", "<C-r>", { desc = "Redo" })
map("i", "<C-y>", "<C-o><C-r>", { desc = "Redo in insert mode" })

-- Add custom keymap to toggle Snacks Explorer
map("n", "<C-t>", function()
  require("config.myfunction").toggle_explorer()
end, { desc = "Toggle Snacks Explorer" })

-- Add custom keymap to toggle Snacks Terminal
map({ "n", "t" }, "<C-g>", function()
  Snacks.terminal()
end, { desc = "Terminal (Root Dir)" })
