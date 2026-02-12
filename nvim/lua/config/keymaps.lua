-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set

-- #region delete
-- Delete without copying to clipboard 削除時にクリップボードにコピーしない
-- すべての削除・変更操作をデフォルトでブラックホールレジスタ "_ に送る

-- ctrl + BS/Del : 単語削除
map({ "i" }, "<C-Del>", '<Esc>`^"_degi')
map({ "n" }, "<C-Del>", '"_deg')
-- <C-BS>としないのは、Backspace → <BS>
-- Ctrl + Backspace → <C-h> となっており <C-BS> が送られてこないため。
map({ "i" }, "<C-h>", "<C-w>")
map({ "n" }, "<C-h>", '"_dbg')

-- -- 削除(d, c, x, s)のデフォルトを "_ に向ける
local noswap_keys = { "d", "D", "c", "C", "s", "S", "x", "X" }
for _, key in ipairs(noswap_keys) do
  map({ "n", "v" }, key, '"_' .. key)
end
-- Delキーも同様
map({ "n", "v" }, "<Del>", '"_d')
-- #endregion delete

-- #region clipboard
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
-- 全選択
map({ "n", "i", "v" }, "<C-a>", "<esc>ggVG", { desc = "Select All" })

-- shift + arrow => visual mode
-- insert mode から normal mode に抜けたときカーソルがずれるため、
-- 「`:移動コマンド」＋「^:最後に挿入モードを終了した位置」 => カーソル位置を保持して visual mode 開始
map({ "i" }, "<S-Right>", "<Esc>`^v<Right>")
map({ "n" }, "<S-Right>", "v<Right>")
map({ "v" }, "<S-Right>", "<Right>")
map({ "i" }, "<S-Left>", "<Esc>v<Left>")
map({ "n" }, "<S-Left>", "v<Left>")
map({ "v" }, "<S-Left>", "<Left>")
map({ "i" }, "<S-Down>", "<Esc>`^v<Down>")
map({ "n" }, "<S-Down>", "v<Down>")
map({ "v" }, "<S-Down>", "<Down>")
map({ "i" }, "<S-Up>", "<Esc>v<Up>")
map({ "n" }, "<S-Up>", "v<Up>")
map({ "v" }, "<S-Up>", "<Up>")
-- shift + move => visual mode
map({ "i" }, "<S-End>", "<Esc>`^v$")
map({ "n" }, "<S-End>", "v$")
map({ "i" }, "<S-Home>", "<Esc>v^")
map({ "n" }, "<S-Home>", "v^")
map({ "i" }, "<S-PageDown>", "<Esc>`^v<C-d>")
map({ "n" }, "<S-PageDown>", "v<C-d>")
map({ "i" }, "<S-PageUp>", "<Esc>v<C-u>")
map({ "n" }, "<S-PageUp>", "v<C-u>")

-- ctrl + shift + arrow : 単語単位選択
map({ "i" }, "<C-S-Right>", "<Esc>`^ve")
map({ "n" }, "<C-S-Right>", "ve")
map({ "i" }, "<C-S-Left>", "<Esc>vb")
map({ "n" }, "<C-S-Left>", "vb")
-- ctrl + arrow : 単語移動
map({ "i" }, "<C-Right>", "<C-o>e")
map({ "n" }, "<C-Right>", "e")
map({ "i" }, "<C-Left>", "<C-o>b")
map({ "n" }, "<C-Left>", "b")

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

-- #region editor

-- 次のバッファへ
map("n", "<Tab>", ":BufferLineCycleNext<CR>", { silent = true })
-- 前のバッファへ
map("n", "<S-Tab>", ":BufferLineCyclePrev<CR>", { silent = true })

-- ウィンドウを垂直分割 (Vertical Split)
map("n", "<A-+>", "<C-w>v", { desc = "Split window vertically" })
-- ウィンドウを水平分割 (Horizontal Split)
map("n", "<A-->", "<C-w>s", { desc = "Split window horizontally" })

-- Alt + Left で前のカーソル位置に戻る (Go Back)
map("n", "<A-Left>", "<C-o>", { desc = "Go Back", remap = false })
-- Alt + Right で次のカーソル位置に進む (Go Forward)
map("n", "<A-Right>", "<C-i>", { desc = "Go Forward", remap = false })
-- Alt + Down で次の差分へ (Next Hunk)
map("n", "<A-Down>", function()
  require("gitsigns").nav_hunk("next")
end, { desc = "Next Change" })
-- Alt + Up で前の差分へ (Prev Hunk)
map("n", "<A-Up>", function()
  require("gitsigns").nav_hunk("prev")
end, { desc = "Prev Change" })

map("n", "<A-S-Left>", "<C-w>h", { desc = "Move focus to left window", remap = true })
map("n", "<A-S-Down>", "<C-w>j", { desc = "Move focus to bottom window", remap = true })
map("n", "<A-S-Up>", "<C-w>k", { desc = "Move focus to top window", remap = true })
map("n", "<A-S-Right>", "<C-w>l", { desc = "Move focus to right window", remap = true })

-- Move Line Up/Down
map("n", "<C-Down>", ':<C-u>execute "move +" . v:count1<CR>==', { silent = true })
map("v", "<C-Down>", ":m '>+1<CR>gv=gv", { silent = true })

map("n", "<C-Up>", ':<C-u>execute "move -1-" . v:count1<CR>==', { silent = true })
map("v", "<C-Up>", ":m '<-2<CR>gv=gv", { silent = true })

-- 折り返しのトグル
map("n", "<A-w>", ":set wrap!<CR>", { noremap = true, silent = true })

map({ "n", "i" }, "<F2>", function()
  vim.lsp.buf.rename()
end, { desc = "Rename" })

-- #endregion
