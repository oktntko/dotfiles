-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set

-- #region clipboard
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
-- #endregion clipboard

-- #region arrow/move
-- shift + arrow => visual mode
-- insert mode から normal mode に抜けたときカーソルがずれるため、
-- 「`:移動コマンド」＋「^:最後に挿入モードを終了した位置」 => カーソル位置を保持して visual mode 開始
map({ "i", --[[ ]] }, "<S-Right>" --[[    ]], "<Esc>`^v<Right>" --[[  ]])
map({ "n", --[[ ]] }, "<S-Right>" --[[    ]], "v<Right>" --[[         ]])
map({ "v", --[[ ]] }, "<S-Right>" --[[    ]], "<Right>" --[[          ]])
map({ "i", --[[ ]] }, "<S-Left>" --[[     ]], "<Esc>v<Left>" --[[     ]])
map({ "n", --[[ ]] }, "<S-Left>" --[[     ]], "v<Left>" --[[          ]])
map({ "v", --[[ ]] }, "<S-Left>" --[[     ]], "<Left>" --[[           ]])
map({ "i", --[[ ]] }, "<S-Down>" --[[     ]], "<Esc>`^v<Down>" --[[   ]])
map({ "n", --[[ ]] }, "<S-Down>" --[[     ]], "v<Down>" --[[          ]])
map({ "v", --[[ ]] }, "<S-Down>" --[[     ]], "<Down>" --[[           ]])
map({ "i", --[[ ]] }, "<S-Up>" --[[       ]], "<Esc>v<Up>" --[[       ]])
map({ "n", --[[ ]] }, "<S-Up>" --[[       ]], "v<Up>" --[[            ]])
map({ "v", --[[ ]] }, "<S-Up>" --[[       ]], "<Up>" --[[             ]])
-- shift + move => visual mode
map({ "i", --[[ ]] }, "<S-End>" --[[      ]], "<Esc>`^v$" --[[        ]])
map({ "n", --[[ ]] }, "<S-End>" --[[      ]], "v$" --[[               ]])
map({ "i", --[[ ]] }, "<S-Home>" --[[     ]], "<Esc>v^" --[[          ]])
map({ "n", --[[ ]] }, "<S-Home>" --[[     ]], "v^" --[[               ]])
map({ "i", --[[ ]] }, "<S-PageDown>" --[[ ]], "<Esc>`^v<C-d>" --[[    ]])
map({ "n", --[[ ]] }, "<S-PageDown>" --[[ ]], "v<C-d>" --[[           ]])
map({ "i", --[[ ]] }, "<S-PageUp>" --[[   ]], "<Esc>v<C-u>" --[[      ]])
map({ "n", --[[ ]] }, "<S-PageUp>" --[[   ]], "v<C-u>" --[[           ]])

-- ctrl + shift + arrow : 単語単位選択
map({ "i", --[[ ]] }, "<C-S-Right>" --[[  ]], "<Esc>`^ve" --[[        ]])
map({ "n", --[[ ]] }, "<C-S-Right>" --[[  ]], "ve" --[[               ]])
map({ "i", --[[ ]] }, "<C-S-Left>" --[[   ]], "<Esc>vb" --[[          ]])
map({ "n", --[[ ]] }, "<C-S-Left>" --[[   ]], "vb" --[[               ]])
-- ctrl + arrow : 単語移動
map({ "i", --[[ ]] }, "<C-Right>" --[[    ]], "<C-o>e" --[[           ]])
map({ "n", --[[ ]] }, "<C-Right>" --[[    ]], "e" --[[                ]])
map({ "i", --[[ ]] }, "<C-Left>" --[[     ]], "<C-o>b" --[[           ]])
map({ "n", --[[ ]] }, "<C-Left>" --[[     ]], "b" --[[                ]])
-- ctrl + BS/Del : 単語削除
map({ "i", --[[ ]] }, "<C-Del>" --[[      ]], "<Esc>`^degi" --[[      ]])
-- <C-BS>としないのは、
-- Backspace → <BS>
-- Ctrl + Backspace → <C-h>
-- となっており <C-BS> が送られてこないため。
map({ "i", --[[ ]] }, "<C-h>" --[[        ]], "<C-w>" --[[            ]])
-- #endregion arrow/move

-- 矩形選択
-- TODO

-- Add custom keymap to toggle Snacks Explorer
map("n", "<C-t>", function()
  require("config.myfunction").toggle_explorer()
end, { desc = "Toggle Snacks Explorer" })

-- Add custom keymap to toggle Snacks Terminal
map({ "n", "t" }, "<C-g>", function()
  Snacks.terminal()
end, { desc = "Terminal (Root Dir)" })

-- 次のバッファへ
map('n', '<Tab>', ':BufferLineCycleNext<CR>', { silent = true })
-- 前のバッファへ
map('n', '<S-Tab>', ':BufferLineCyclePrev<CR>', { silent = true })
