-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set

-- #region delete
-- Delete without copying to clipboard 削除時にクリップボードにコピーしない
-- すべての削除・変更操作をデフォルトでブラックホールレジスタ "_ に送る

-- ctrl + BS/Del : 単語削除
map({ "i" }, "<C-Del>", '<Esc>`^"_degi')
map({ "n" }, "<C-Del>", '"_de')
map({ "i" }, "<C-h>", "<C-w>") -- <C-BS> = ^h = <C-h>
map({ "n" }, "<C-h>", '"_db')

-- -- 削除(d, c, x, s)のデフォルトを "_ に向ける
local noswap_keys = { "d", "D", "c", "C", "s", "S", "x", "X" }
for _, key in ipairs(noswap_keys) do
  map({ "n", "v" }, key, '"_' .. key)
end
map({ "v" }, "<BS>", '"_d')
map({ "v" }, "<Del>", '"_d')

-- 改行コードも削除できるようにする
map({ "n" }, "<BS>", function()
  return vim.fn.col(".") == 1 and "kJ" or '"_X'
end, { expr = true })

map({ "n" }, "<Del>", function()
  return vim.fn.col(".") > vim.fn.col("$") - 1 and "J" or '"_x'
end, { expr = true })
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

map({ "i", "n", "v" }, "<C-f>", "<Esc>/", { desc = "Search" })
map({ "c" }, "<C-f>", "<Esc>", { desc = "Cancel Search" })

map({ "n", "v" }, "<cr>", "<Esc>i", { desc = "Start Insert mode by Enter" })

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
-- #region editor

-- 次のバッファへ
map("n", "<Tab>", ":BufferLineCycleNext<CR>", { silent = true })
-- 前のバッファへ
map("n", "<S-Tab>", ":BufferLineCyclePrev<CR>", { silent = true })

-- タブ移動 Diffview はタブを作成するため
map("n", "<C-Tab>", ":tabnext<CR>", { noremap = true, silent = true })
map("n", "<C-S-Tab>", ":tabprevious<CR>", { noremap = true, silent = true })

-- ウィンドウを垂直分割 (Vertical Split)
map("n", "<A-+>", "<C-w>v", { desc = "Split window vertically" })
-- ウィンドウを水平分割 (Horizontal Split)
map("n", "<A-->", "<C-w>s", { desc = "Split window horizontally" })

-- Alt + Left で前のカーソル位置に戻る (Go Back)
map("n", "<A-Left>", "<C-o>", { desc = "Go Back", remap = false })
-- Alt + Right で次のカーソル位置に進む (Go Forward)
map("n", "<A-Right>", "<C-i>", { desc = "Go Forward", remap = false })

map("n", "<A-S-Left>", "<C-w>h", { desc = "Move focus to left window", remap = true })
map("n", "<A-S-Down>", "<C-w>j", { desc = "Move focus to bottom window", remap = true })
map("n", "<A-S-Up>", "<C-w>k", { desc = "Move focus to top window", remap = true })
map("n", "<A-S-Right>", "<C-w>l", { desc = "Move focus to right window", remap = true })

-- ウィンドウのリサイズ（Ctrl + 矢印キー）
map("n", "<A-S-C-Up>", "<cmd>resize +1<cr>", { desc = "Increase window height" })
map("n", "<A-S-C-Down>", "<cmd>resize -1<cr>", { desc = "Decrease window height" })
map("n", "<A-S-C-Left>", "<cmd>vertical resize -1<cr>", { desc = "Decrease window width" })
map("n", "<A-S-C-Right>", "<cmd>vertical resize +1<cr>", { desc = "Increase window width" })

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

-- かっこでくくる
-- c は「変更（change）」コマンド。選択範囲を消去してインサートモードに入ります
-- インサートモードで入力（""、''など）
-- <Esc> ノーマルモードに戻る
-- P はカーソルの直前に貼り付けなので、間に入力される
-- レジスタを汚さないように ブラックホールレジスタ を使う
map("v", '"', [["-c""<Esc>"-P]], { noremap = true })
map("v", "'", [["-c''<Esc>"-P]], { noremap = true })
map("v", "`", [["-c``<Esc>"-P]], { noremap = true })
map("v", "(", [["-c()<Esc>"-P]], { noremap = true })
map("v", "[", [["-c[]<Esc>"-P]], { noremap = true })
map("v", "{", [["-c{}<Esc>"-P]], { noremap = true })
map("v", "<", [["-c<><Esc>"-P]], { noremap = true })
map("v", "（", [["-c（）<Esc>"-P]], { noremap = true })
map("v", "「", [["-c「」<Esc>"-P]], { noremap = true })
map("v", "＜", [["-c＜＞<Esc>"-P]], { noremap = true })

-- 検索入力中に Ctrl-c で大文字小文字区別 (\C) をトグル
map("c", "<C-c>", function()
  local cmd = vim.fn.getcmdline()
  if cmd:find([[\C]]) then
    vim.fn.setcmdline(cmd:gsub([[\C]], ""))
  else
    vim.fn.setcmdline(cmd .. [[\C]])
  end
end, { desc = "Toggle Case Sensitivity in Search" })

-- 検索入力中に Ctrl-w で単語単位検索 (\< \>) をトグル (Whole Word)
map("c", "<A-w>", function()
  local cmd = vim.fn.getcmdline()
  if cmd:find([[\<]]) then
    -- \< と \> を削除
    local new_cmd = cmd:gsub([[\<]], ""):gsub([[\>]], "")
    vim.fn.setcmdline(new_cmd)
  else
    vim.fn.setcmdline([[\<]] .. cmd .. [[\>]])
  end
end, { desc = "Toggle Whole Word Search" })

-- #endregion

-- 右にスクロール（画面を右へ動かす = 内容は左へ流れる）
map({ "n", "i", "v" }, "<S-ScrollWheelDown>", "5zl", { silent = true })

-- 左にスクロール（画面を左へ動かす = 内容は右へ流れる）
map({ "n", "i", "v" }, "<S-ScrollWheelUp>", "5zh", { silent = true })
