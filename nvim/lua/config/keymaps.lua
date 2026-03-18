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

local no_keys = {
  -- "a",
  "b",
  -- "c",
  "d",
  "e",
  "f",
  -- "g",
  "h",
  -- "i",
  "j",
  "k",
  "l",
  "m",
  -- "n",
  "o",
  "p",
  -- "q",
  -- "r",
  -- "s",
  "t",
  "u",
  -- "v",
  "w",
  "x",
  -- "y",
  -- "z",
  ",",
  ".",
  -- "1",
  -- "2",
  -- "3",
  -- "4",
  -- "5",
  -- "6",
  -- "7",
  -- "8",
  -- "9",
  -- "0",
}
for _, key in ipairs(no_keys) do
  map({ "n" }, key, "")
end

-- -- 削除(d, c, x, s)のデフォルトを "_ に向ける
local noswap_keys = { "d", "D", "c", "C", "x", "X", "p", "P" }
for _, key in ipairs(noswap_keys) do
  map({ "x" }, key, '"_' .. key)
end
map({ "x" }, "<BS>", '"_d')
map({ "x" }, "<Del>", '"_d')

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
-- "y"だとカーソルが選択範囲の最初に戻るため "y" した後 "gv" で 直前の visual 範囲を再選択
map("x", "<C-c>", "ygv<Esc>", { desc = "Copy selection", noremap = true })
-- mz (位置zにマーク) -> viwy (ヤンク) -> `z (位置zに戻る)
-- bve だと 単語の先頭文字にカーソルがあると前の単語にカーソルが移動する
map("n", "<C-S-c>", "mzviwy`z", { desc = "Copy word" })

-- Ctrl+X: Cut
map("n", "<C-x>", "dd", { desc = "Cut line" })
map("x", "<C-x>", "d", { desc = "Cut selection" })
map("n", "<C-S-x>", "mzviwd`z", { desc = "Cut word" })

-- Ctrl+V: Paste
-- vim.o.paste = true ペーストしたときにインデントが崩れるのを防ぐ
map({ "n" }, "<C-v>", function()
  local paste = vim.o.paste
  vim.o.paste = true
  vim.cmd("normal! gP")
  vim.o.paste = paste
end, { desc = "Paste", noremap = true })
map({ "i", "c" }, "<C-v>", function()
  local paste = vim.o.paste
  vim.o.paste = true

  local keys = vim.api.nvim_replace_termcodes("<C-r>+", true, false, true)
  vim.api.nvim_feedkeys(keys, "n", false)

  vim.schedule(function()
    vim.o.paste = paste
  end)
end, { desc = "Paste", noremap = true })
map({ "x" }, "<C-v>", function()
  local paste = vim.o.paste
  vim.o.paste = true
  vim.cmd('normal! "_dgP')
  vim.o.paste = paste
end, { desc = "Paste", noremap = true })

-- Ctrl+Z: Undo
map("n", "<C-z>", "u", { desc = "Undo" })
map("i", "<C-z>", "<Cmd>undo<CR>", { desc = "Undo in insert mode" })

-- Ctrl+Y: Redo
map("n", "<C-y>", "<C-r>", { desc = "Redo" })
-- #endregion clipboard

map({ "i", "n", "x" }, "<C-f>", "<Esc>/", { desc = "Search" })
map({ "c" }, "<C-f>", "<Esc>", { desc = "Cancel Search" })

-- 共通：置換コマンド生成
local function start_replace(text)
  -- 完全一致 + case-sensitive
  local pattern = "\\C\\V" .. vim.fn.escape(text, "\\/")
  vim.fn.setreg("/", pattern)

  -- 置換コマンドをプリセット（入力待機）
  vim.api.nvim_feedkeys(
    vim.api.nvim_replace_termcodes(":%s//" .. text .. "/gc" .. string.rep("<Left>", 3), true, false, true),
    "nt",
    false
  )
end

-- ノーマルモード：カーソル単語
map("n", "<C-r>", function()
  local word = vim.fn.expand("<cword>")
  start_replace(word)
end, { desc = "Replace word (case-sensitive)" })

-- ビジュアルモード：選択範囲
map("x", "<C-r>", function()
  local old_reg = vim.fn.getreg('"')
  vim.cmd('normal! "vy')
  local selection = vim.fn.getreg("v")
  vim.fn.setreg('"', old_reg)
  start_replace(selection)
end, { desc = "Replace selection (case-sensitive)" })

map("i", "<C-r>", function()
  vim.cmd("stopinsert")
  local word = vim.fn.expand("<cword>")
  start_replace(word)
end, { desc = "Replace word" })

map({ "n" }, "<F3>", "n", { desc = "Next" })
map({ "n" }, "<F15>", "N", { desc = "Prev" })
map({ "n", "x" }, "<cr>", "<Esc>i", { desc = "Start Insert mode by Enter" })
map({ "n", "x" }, "<A-cr>", "<Esc>A", { desc = "Start Insert mode by Enter" })
map({ "n", "x" }, "<C-cr>", "<Esc>o", { desc = "Start Insert mode by Enter" })
map({ "n", "x" }, "<S-cr>", "<Esc>I", { desc = "Start Insert mode by Enter" })
map({ "n", "x" }, "<C-S-cr>", "", { desc = "" }) -- 使うかもしれないので残しておく
-- <A-S-cr> , <C-A-cr>, <C-A-S-cr> は Windows Terminal のキーマップを変更しても効かなかった

-- PageUpで画面が最上部まで戻れない
map({ "n", "x", "i" }, "<PageUp>", "<C-u>")
map({ "n", "x", "i" }, "<PageDown>", "<C-d>")

-- #region arrow/move
-- 全選択
map({ "n" }, "<C-a>", "ggVG", { desc = "Select All" })
map({ "i", "v" }, "<C-a>", "<esc>ggVG", { desc = "Select All" })

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
map({ "i" }, "<C-Right>", "<C-o>e<Right>")
map({ "n" }, "<C-Right>", "e")
map({ "i" }, "<C-Left>", "<C-o>b")
map({ "n" }, "<C-Left>", "b")
-- #endregion arrow/move
-- #region editor

-- タブ移動 Diffview はタブを作成するため
map("n", "<C-Tab>", ":tabnext<CR>", { noremap = true, silent = true })
map("n", "<C-S-Tab>", ":tabprevious<CR>", { noremap = true, silent = true })

map("n", "<C-k>", function()
  local util_keys = require("util.keys")
  local buf = vim.api.nvim_get_current_buf()

  local function open_item()
    vim.api.nvim_win_set_buf(0, buf)
  end

  util_keys.smart_split("left", open_item)
end, { desc = "Split window(max 2) and open left" })

map("n", "<C-l>", function()
  local util_keys = require("util.keys")
  local buf = vim.api.nvim_get_current_buf()

  local function open_item()
    vim.api.nvim_win_set_buf(0, buf)
  end

  util_keys.smart_split("right", open_item)
end, { desc = "Split window(max 2) and open right" })

-- ウィンドウを | 方向に分割
map("n", "<A-+>", "<C-w>v", { desc = "Split window vertically" })
-- ウィンドウを - 方向に分割
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

-- 検索入力中に Alt-c で大文字小文字区別 (\C) をトグル
map("c", "<A-c>", function()
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

-- ※横スクロールははみ出している行にカーソルを置かないと効かない
-- 右にスクロール（画面を右へ動かす = 内容は左へ流れる）
map({ "n", "i", "v" }, "<A-ScrollWheelDown>", "5zl", { silent = true })

-- 左にスクロール（画面を左へ動かす = 内容は右へ流れる）
map({ "n", "i", "v" }, "<A-ScrollWheelUp>", "5zh", { silent = true })

map({ "n", "x" }, "<C-Space>", function()
  vim.lsp.buf.code_action()
end, { desc = "Code Action" })
map({ "n", "x" }, "<C-S-Space>", function()
  vim.lsp.buf.code_action({
    context = {
      diagnostics = {},
      only = {
        "quickfix",
        "refactor",
        "source",
      },
    },
  })
end, { desc = "Code Action" })

local function feed_fold(keys)
  -- 'm' はマッピングを再帰的に展開し、'n' はノード（ノーマルモード）での実行を意味する
  -- t: ターミナルコードなどの変換を有効にする
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, false, true), "n", false)
end

-- nowait を付けてもマッピングが競合して遅れるなら、そもそも「マッピング」として定義しない
-- しかし、これだと < を上書きできないので、以下のように設定
map("n", ">", function()
  feed_fold("zo")
end, { desc = "open fold", nowait = true, silent = true })
map("n", "<", function()
  feed_fold("zc")
end, { desc = "close fold", nowait = true, silent = true })

-- Ctrl + j で行番号入力プロンプトを出す
map("n", "<C-j>", function()
  local line = vim.fn.input("Goto Line: ")
  if line ~= "" then
    vim.cmd(line)
  end
end, { desc = "Goto line (absolute)" })
-- ほかのジャンプの仕方
-- [行番号]G (例) 120G
-- [行番号]gg (例) 120gg
-- :[行番号]<Enter> (例) :120
