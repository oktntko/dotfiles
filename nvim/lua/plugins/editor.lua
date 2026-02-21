return {
  -- 入力補完
  {
    "saghen/blink.cmp",
    opts = {
      keymap = {
        preset = "enter", -- Enterで確定する基本スタイル

        -- Tabでメニューの最初の項目を選択し、次へと進む設定
        ["<Tab>"] = { "select_next", "fallback" },
        ["<S-Tab>"] = { "select_prev", "fallback" },
      },
      completion = {
        list = {
          selection = {
            -- ここを 'preselect' にすると、メニューが出た瞬間に1番目が選択状態になります
            -- 'manual' だと、Tabを1回叩いた時に1番目が選択されます
            preselect = false,
            auto_insert = true,
          },
        },
      },
    },
  },

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

  {
    "MagicDuck/grug-far.nvim",
    keys = {
      {
        "<C-S-r>",
        function()
          local function tab_has_grug(tab)
            for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tab)) do
              local buf = vim.api.nvim_win_get_buf(win)
              if vim.bo[buf].filetype == "grug-far" then
                return true
              end
            end
            return false
          end

          -- grug-far に移動するとデフォルトで insert になっている。
          -- トグルして戻ると元々が何のモードでも insert が残るので強制的に戻す。
          vim.cmd("stopinsert")

          local current_tab = vim.api.nvim_get_current_tabpage()

          -- ① 現在タブにあるならタブごと閉じる
          if tab_has_grug(current_tab) then
            vim.cmd("tabclose")
            return
          end

          -- ② 他タブにあるか探す
          for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
            if tab ~= current_tab and tab_has_grug(tab) then
              vim.api.nvim_set_current_tabpage(tab)
              return
            end
          end

          -- ③ どこにもなければ新規タブで開く
          local grug = require("grug-far")
          local ext = vim.bo.buftype == "" and vim.fn.expand("%:e")
          grug.open({
            transient = true,
            windowCreationCommand = "tab split",
            openTargetWindow = {
              preferredLocation = "right",
            },
            prefills = {
              filesFilter = ext and ext ~= "" and "*." .. ext or nil,
              flags = "--smart-case --word-regexp",
              -- -w / --word-regexp    単語単位
              -- -i / --ignore-case    大文字小文字無視
              -- -s / --case-sensitive 常に区別
              -- -S / --smart-case     大文字含むと区別
            },
          })
        end,
        mode = { "i", "n", "x" },
        desc = "Toggle Search and Replace",
      },
    },
    opts = function(_, opts)
      opts.keymaps = opts.keymaps or {}

      opts.keymaps.gotoLocation = {
        n = "<localleader>o",
      }
      opts.keymaps.openLocation = {
        n = "<localleader>e",
      }
      opts.keymaps.swapEngine = {
        n = false,
      }
    end,
  },
}
