local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = {
    -- add LazyVim and import its plugins
    { "LazyVim/LazyVim", import = "lazyvim.plugins" },
    -- import/override with your plugins
    { import = "plugins" },
  },
  defaults = {
    -- By default, only LazyVim plugins will be lazy-loaded. Your custom plugins will load during startup.
    -- If you know what you're doing, you can set this to `true` to have all your custom plugins lazy-loaded by default.
    lazy = false,
    -- It's recommended to leave version=false for now, since a lot the plugin that support versioning,
    -- have outdated releases, which may break your Neovim install.
    version = false, -- always use the latest git commit
    -- version = "*", -- try installing the latest stable version for plugins that support semver
  },
  install = { colorscheme = { "tokyonight" } },
  checker = {
    enabled = true, -- check for plugin updates periodically
    notify = false, -- notify on update
  }, -- automatically check for plugin updates
  performance = {
    rtp = {
      -- disable some rtp plugins
      disabled_plugins = {
        "gzip", -- .gz ファイルを直接開いて編集する機能
        -- "matchit", -- 対応するカッコ（() や {}）をハイライトしたり、% キーで移動したりする機能
        -- "matchparen", -- 対応するカッコ（() や {}）をハイライトしたり、% キーで移動したりする機能
        "netrwPlugin", -- Neovim標準のファイルブラウザ
        "tarPlugin", -- .tar ファイルの中身を閲覧する機能
        "tohtml", -- コードをHTML形式に変換する機能（:TOhtml）
        "tutor", -- 初心者向けのチュートリアル（:Tutor）
        "zipPlugin", -- .zip ファイルの中身を閲覧する機能
        "getscript", -- Vimスクリプトを自動更新する古い仕組み
        "getscriptPlugin",
        "logipat", -- 論理パターン（AND/ORなど）で検索する機能
        "rrhelper", -- 置換の履歴を管理する古いヘルパー
        "vimball", -- .vba という古い形式のプラグインアーカイブを扱う機能
        "vimballPlugin",
      },
    },
  },
})
