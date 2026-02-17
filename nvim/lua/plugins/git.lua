-- 差分表示時にファイルすべてを表示する
vim.opt.diffopt:append("context:99999")

return {
  {
    "sindrets/diffview.nvim",
    -- gitsigns が先に読み込まれていることを保証（依存関係の明示）
    dependencies = { "lewis6991/gitsigns.nvim" },
    keys = {
      { "<leader>gg", "<cmd>DiffviewFileHistory<cr>", mode = { "n" }, desc = "Diffview: Repo history" },
      { "<leader>gH", "<cmd>DiffviewFileHistory %<cr>", mode = { "n" }, desc = "Diffview: Current file history" },
    },
    opts = function()
      local actions = require("diffview.actions")

      -- --- 共通アクションの定義 ---

      -- リストアする前に確認する
      local function restore_entry_with_conf()
        local confirm = vim.fn.confirm("Restore entry?", "&Yes\n&No", 2)
        if confirm == 1 then
          actions.restore_entry()
        end
      end

      -- 行単位ステージング (gitsigns連携)
      local function stage_hunk_smart()
        local gs = package.loaded.gitsigns -- ロード済みなら取得
        if not gs then
          return
        end

        local mode = vim.api.nvim_get_mode().mode
        if mode:sub(1, 1) == "v" or mode:sub(1, 1) == "V" then
          -- ビジュアルモード
          gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
          vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
        else
          -- ノーマルモード
          gs.stage_hunk()
        end
      end

      -- 行単位アンステージ (diffget連携)
      local function unstage_hunk_smart()
        vim.cmd("diffget")
        vim.cmd("silent! write")
        -- 選択モード中なら抜ける
        local mode = vim.api.nvim_get_mode().mode
        if mode:sub(1, 1) == "v" or mode:sub(1, 1) == "V" then
          vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
        end
        print("Line(s) unstaged.")
      end

      -- --- 設定本体 ---
      return {
        enhanced_diff_hl = true,
        file_panel = {
          win_config = {
            position = "left",
            width = 40,
          },
        },
        keymaps = {
          view = {
            { "n", "e", actions.goto_file_edit, { desc = "Open the file" } },
            { "n", "X", restore_entry_with_conf, { desc = "Restore entry with confirmation" } },
            { { "n", "v" }, "s", stage_hunk_smart, { desc = "Stage hunk/range" } },
            { { "n", "v" }, "u", unstage_hunk_smart, { desc = "Unstage hunk/range" } },
          },
          file_panel = {
            { "n", "e", actions.goto_file_edit, { desc = "Open the file" } },
            { "n", "X", restore_entry_with_conf, { desc = "Restore entry with confirmation" } },
            {
              "n",
              "<A-Down>",
              function()
                require("gitsigns").nav_hunk("next")
              end,
              { desc = "Next Change" },
            },
            {
              "n",
              "<A-Up>",
              function()
                require("gitsigns").nav_hunk("prev")
              end,
              { desc = "Prev Change" },
            },
          },
          file_history_panel = {
            { "n", "e", actions.goto_file_edit, { desc = "Open the file" } },
          },
        },
      }
    end,
  },
  {
    "lewis6991/gitsigns.nvim",
    opts = {},
  },
}
