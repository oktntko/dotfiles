return {
  "b0o/incline.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" }, -- アイコン表示に必要
  event = "VeryLazy",
  opts = function()
    return {
      -- render関数は、ウィンドウの右上に表示する内容を定義します
      render = function(props)
        -- 1. ファイル名の取得と整形
        local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ":t")
        if filename == "" then
          filename = "[No Name]"
        end

        -- 2. ファイルタイプに応じたアイコンと色の取得
        local ft_icon, ft_color = require("nvim-web-devicons").get_icon_color(filename)

        -- 3. Gitの差分情報（追加/変更/削除）を取得する関数
        local function get_git_diff()
          local icons = { removed = "", changed = "", added = "" }
          local signs = vim.b[props.buf].gitsigns_status_dict -- gitsignsプラグインのデータを利用
          local labels = {}
          if signs == nil then
            return labels
          end
          for name, icon in pairs(icons) do
            if tonumber(signs[name]) and signs[name] > 0 then
              -- 例: " 3 " のようなラベルを作成し、Gitのハイライト色を適用
              table.insert(labels, { icon .. signs[name] .. " ", group = "Diff" .. name })
            end
          end
          if #labels > 0 then
            table.insert(labels, { "┊ " }) -- 区切り線
          end
          return labels
        end

        -- 4. LSP診断（エラーや警告）の件数を取得する関数
        local function get_diagnostic_label()
          local icons = { error = "", warn = "", info = "", hint = "" }
          local label = {}

          for severity, icon in pairs(icons) do
            -- 各重要度ごとのエラー件数を取得
            local n = #vim.diagnostic.get(props.buf, { severity = vim.diagnostic.severity[string.upper(severity)] })
            if n > 0 then
              -- 例: " 1 " のようなラベルを作成し、エラー用の色を適用
              table.insert(label, { icon .. n .. " ", group = "DiagnosticSign" .. severity })
            end
          end
          if #label > 0 then
            table.insert(label, { "┊ " }) -- 区切り線
          end
          return label
        end

        -- 5. 最終的な表示内容を組み立てて返す
        return {
          { get_diagnostic_label() },                                   -- 左側：エラー情報
          { get_git_diff() },                                           -- 中間：Git情報
          { (ft_icon or "") .. " ", guifg = ft_color, guibg = "none" }, -- アイコン
          {
            filename .. " ",
            -- ファイルが編集中の場合は太字＋斜体、そうでなければ太字
            gui = vim.bo[props.buf].modified and "bold,italic" or "bold",
          },
          { "┊  " .. vim.api.nvim_win_get_number(props.win), group = "DevIconWindows" }, -- 右端：ウィンドウ番号
        }
      end,
    }
  end,
}
