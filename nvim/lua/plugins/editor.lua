return {
  -- 1. LazyVim標準の mini.comment を無効化
  { "nvim-mini/mini.comment", enabled = false },

  -- 2. Comment.nvim の設定
  {
    "numToStr/Comment.nvim",
    keys = {
      -- 行コメントアウト (Ctrl + .)
      { "<C-.>", "<Plug>(comment_toggle_linewise_current)", mode = "n", desc = "Comment line" },
      { "<C-.>", "<Plug>(comment_toggle_linewise_visual)", mode = "v", desc = "Comment line" },
      -- ブロックコメントアウト (Ctrl + / or ?)
      { "<C-?>", "<Plug>(comment_toggle_blockwise_current)", mode = "n", desc = "Comment block" },
      { "<C-?>", "<Plug>(comment_toggle_blockwise_visual)", mode = "v", desc = "Comment block" },
    },
    dependencies = {
      -- コンテキスト判定プラグイン
      {
        "JoosepAlviste/nvim-ts-context-commentstring",
        opts = {
          enable_autocmd = false, -- パフォーマンスのためにAutocmdをオフにする
        },
      },
    },
    config = function()
      require("Comment").setup({
        -- ここで pre_hook を設定！
        -- コメント実行直前にコンテキストを計算する公式推奨の統合方法
        pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
      })
    end,
  },
}
