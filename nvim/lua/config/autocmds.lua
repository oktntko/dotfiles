-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

vim.api.nvim_create_autocmd("FileType", {
  pattern = "*",
  callback = function()
    -- formatoptions = 貼り付け時の自動コメントアウトを無効にする
    vim.opt_local.formatoptions:remove({ "r", "o" })
  end,
})

vim.api.nvim_create_autocmd("CmdlineEnter", {
  pattern = "*",
  callback = function()
    require("smear_cursor").enabled = false
  end,
})

vim.api.nvim_create_autocmd("CmdlineLeave", {
  pattern = "*",
  callback = function()
    require("smear_cursor").enabled = true
  end,
})
