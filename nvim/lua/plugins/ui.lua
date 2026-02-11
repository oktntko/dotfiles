return {
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = function(_, opts)
      opts.sections.lualine_x = {
        -- 1. ファイルタイプ (例: typescript, lua, python)
        {
          "filetype",
          icon_only = false, -- アイコンだけでなく名前も出す
          separator = { left = "", right = "" },
          color = { fg = "#ff9e64", gui = "bold" },
          on_click = function()
            LazyVim.format.info()
          end,
        },

        -- 2. LSPサーバー名
        {
          function()
            -- 1. 特殊なバッファ（ピッカー等）なら何も出さない
            local buftype = vim.api.nvim_get_option_value("buftype", { buf = 0 })
            if buftype ~= "" then
              return ""
            end

            -- 2. バッファの作成時刻を記録（なければ現在の時刻をセット）
            local buf = vim.api.nvim_get_current_buf()
            local now = vim.loop.now() -- ミリ秒単位

            -- バッファごとの初回アクセス時刻を保持する変数がなければ初期化
            if not vim.b[buf].opened_at then
              vim.b[buf].opened_at = now
            end

            -- 3. LSPクライアントの取得
            local clients = vim.lsp.get_clients({ bufnr = 0 })

            -- LSPが見つかった場合は即座に表示
            if next(clients) ~= nil then
              local client_names = {}
              for _, client in ipairs(clients) do
                table.insert(client_names, client.name)
              end
              return " " .. table.concat(client_names, "|")
            end

            -- 4. LSPが見つからない場合、経過時間をチェック
            local elapsed = now - vim.b[buf].opened_at

            if elapsed < 250 then
              -- 0.25秒（250ms）以内なら「ロード中」扱いにして No LSP を隠す
              return "󱑮 Loading..."
            else
              -- 0.25秒経ってもLSPがいなければ、本当にLSPがないと判断
              return "No LSP"
            end
          end,
          color = { fg = "#7aa2f7", gui = "bold" },
          separator = { left = "", right = "" },
        },
      }
    end,
  },

  {
    "akinsho/bufferline.nvim",
    opts = {
      options = {
        -- 常にタブを表示する
        always_show_bufferline = true,
        -- 左クリックで buffer 切り替え（デフォルトの挙動）
        -- left_mouse_command = "buffer %d",
        -- ミドルクリックで 閉じる
        middle_mouse_command = "bdelete! %d",
        -- 右クリックで 縦分割
        right_mouse_command = "vertical sbuffer %d",
      },
    },
  },

  {
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
            { get_diagnostic_label() }, -- 左側：エラー情報
            { get_git_diff() }, -- 中間：Git情報
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
  },

  -- フォーカス外のウィンドウを暗くする
  {
    "levouh/tint.nvim",
    event = "VeryLazy",
    opts = {
      -- 暗さの度合い
      tint = -30, -- Darken colors, use a positive value to brighten
      -- サチュレーション（彩度）を落とす設定
      saturation = 0.6, -- Saturation to preserve

      window_ignore_function = function(winid)
        local bufid = vim.api.nvim_win_get_buf(winid)
        local buftype = vim.api.nvim_buf_get_option(bufid, "buftype")
        local floating = vim.api.nvim_win_get_config(winid).relative ~= ""

        -- Do not tint `terminal` or floating windows, tint everything else
        return buftype == "terminal" or floating
      end,
    },
  },

  {
    "hedyhli/outline.nvim",
    lazy = true,
    cmd = { "Outline", "OutlineOpen" },
    keys = { -- Example mapping to toggle outline
      { "<C-o>", "<cmd>Outline<CR>", desc = "Toggle outline" },
    },
    opts = {
      -- Your setup opts here
      outline_window = {
        -- Where to open the split window: right/left
        position = "right",
        -- Percentage or integer of columns; serves as the base/minimum width
        -- for the outline window (and for auto_width calculations)
        width = 20,
        -- The default split commands used are 'topleft vs' and 'botright vs'
        -- depending on `position`. You can change this by providing your own
        -- `split_command`.
        -- `position` will not be considered if `split_command` is non-nil.
        -- This should be a valid vim command used for opening the split for the
        -- outline window. Eg, 'rightbelow vsplit'.
        -- Width can be included (with will override the width setting below):
        -- Eg, `topleft 20vsp` to prevent a flash of windows when resizing.
        split_command = "belowright",
      },
    },
  },

  -- 高機能スクロールバー (nvim-scrollbar)
  {
    "petertriho/nvim-scrollbar",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = {
      "kevinhwang91/nvim-hlslens",
      "lewis6991/gitsigns.nvim",
    },
    opts = {
      handlers = {
        cursor = true,
        diagnostic = true,
        gitsigns = true,
        handle = true,
        search = true,
      },
    },
  },

  -- 関数を sticky にする
  {
    "nvim-treesitter/nvim-treesitter-context",
    opts = {},
  },
}
