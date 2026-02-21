local util_keys = require("util.keys")

-- Diffview 介護 マウスホイールでスクロールすると差分の位置がずれる
-- マウススクロール時にウィンドウを自動でフォーカスする
local function mouse_scroll_with_focus(direction)
  local mouse_pos = vim.fn.getmousepos()
  local winid = mouse_pos.winid

  -- マウスの下に有効なウィンドウがある場合
  if winid > 0 and winid ~= vim.api.nvim_get_current_win() then
    -- ウィンドウをフォーカス
    vim.api.nvim_set_current_win(winid)
  end

  -- スクロールを実行 (feedkeys を使って本来の挙動をシミュレート)
  local key = direction == "up" and "<ScrollWheelUp>" or "<ScrollWheelDown>"
  -- 'n' は再帰的なマッピングを避け、't' はキーをそのまま送るフラグ
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, false, true), "nt", false)
end

return {
  {
    "sindrets/diffview.nvim",
    dependencies = { "lewis6991/gitsigns.nvim" },
    keys = {
      {
        "<C-g>",
        function()
          util_keys.toggle_diffview("DiffviewOpen")
        end,
        mode = { "n", "v" },
        desc = "Diffview: toggle diffview",
      },
      {
        "<C-S-g>",
        function()
          util_keys.toggle_diffview("DiffviewFileHistory")
        end,
        mode = { "n", "v" },
        desc = "Diffview: toggle repo history",
      },
      {
        "<leader>gH",
        "<cmd>DiffviewFileHistory %<cr>",
        mode = { "n" },
        desc = "Diffview: open file history",
      },
      {
        "<ScrollWheelUp>",
        function()
          mouse_scroll_with_focus("up")
        end,
        mode = { "n", "v" },
      },
      {
        "<ScrollWheelDown>",
        function()
          mouse_scroll_with_focus("down")
        end,
        mode = { "n", "v" },
      },
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
          -- 中央のウィンドウ
          view = {
            { "n", "e", actions.goto_file_edit, { desc = "Open the file" } },
            { "n", "X", restore_entry_with_conf, { desc = "Restore entry with confirmation" } },
            { { "n", "v" }, "s", stage_hunk_smart, { desc = "Stage hunk/range" } },
            { { "n", "v" }, "u", unstage_hunk_smart, { desc = "Unstage hunk/range" } },
            {
              "n",
              "<A-Down>",
              "]c",
              { desc = "Next Change" },
            },
            {
              "n",
              "<A-Up>",
              "[c",
              { desc = "Prev Change" },
            },
            { "n", "<C-e>", actions.toggle_files, { desc = "Toggle the file panel" } },
          },
          -- diffview の左側のウィンドウ
          file_panel = {
            { "n", "e", actions.goto_file_edit, { desc = "Open the file" } },
            { "n", "X", restore_entry_with_conf, { desc = "Restore entry with confirmation" } },
            { "n", "<C-e>", actions.toggle_files, { desc = "Toggle the file panel" } },
          },
          -- filehistory の下側のウィンドウ
          file_history_panel = {
            { "n", "e", actions.goto_file_edit, { desc = "Open the file" } },
            { "n", "o", actions.open_in_diffview, { desc = "Open the entry under the cursor in a diffview" } },
            { "n", "<C-e>", actions.toggle_files, { desc = "Toggle the file panel" } },
          },
        },
      }
    end,
  },
  {
    "lewis6991/gitsigns.nvim",
    keys = function()
      local gs = require("gitsigns")

      return {
        {
          "<A-Down>",
          function()
            gs.nav_hunk("next")
          end,
          mode = { "n" },
          desc = "Next Change",
        },
        {
          "<A-Up>",
          function()
            gs.nav_hunk("prev")
          end,
          mode = { "n" },
          desc = "Prev Change",
        },
      }
    end,
  },
}
