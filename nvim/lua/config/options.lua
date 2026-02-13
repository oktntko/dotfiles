-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- 行末で <Right> => 次の行の行頭, 行頭で <Left> => 前の行の行末
vim.opt.whichwrap:append("<,>,[,]")

-- 行番号の相対表示を無効化する
vim.opt.relativenumber = false

-- 右クリックで選択範囲を拡張し、ポップアップメニューを表示させない
vim.opt.mousemodel = "extend"
