return {

  -- colorscheme
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = function(_, opts)
      opts.style = "night"
    end,
  },

  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = function(_, opts)
      local icons = LazyVim.config.icons

      opts.sections.lualine_c = {
        LazyVim.lualine.root_dir(),
        {
          "diagnostics",
          symbols = {
            error = icons.diagnostics.Error,
            warn = icons.diagnostics.Warn,
            info = icons.diagnostics.Info,
            hint = icons.diagnostics.Hint,
          },
        },
      }

      opts.sections.lualine_z = opts.sections.lualine_y
      opts.sections.lualine_y = opts.sections.lualine_x
      opts.sections.lualine_x = {
        -- 1. ファイルタイプ (例: typescript, lua, python)
        { "filetype" },
        -- 2. LSPサーバー名
        {
          function()
            -- 1. 特殊なバッファ（ピッカー等）なら何も出さない
            local buftype = vim.api.nvim_get_option_value("buftype", { buf = 0 })
            if buftype ~= "" then
              return ""
            end

            local servers = {}
            local linters = {}

            -- LSPクライアントをスキャン
            local clients = vim.lsp.get_clients({ bufnr = 0 })
            for _, client in ipairs(clients) do
              -- 汎用的な判別ロジック:
              -- 補完(completion)や定義ジャンプ(definition)を持っていれば「言語サーバ」
              -- それらがなく、診断(publishDiagnostics)がメインなら「Linter」とみなす
              local caps = client.server_capabilities
              if caps and (caps.completionProvider or caps.definitionProvider or caps.hoverProvider) then
                table.insert(servers, client.name)
              else
                table.insert(linters, client.name)
              end
            end

            -- nvim-lint (LSPでない純粋なLinter) も加える
            local ok, lint = pcall(require, "lint")
            if ok then
              for _, linter in ipairs(lint.get_running()) do
                if not vim.tbl_contains(linters, linter) then
                  table.insert(linters, linter)
                end
              end
            end

            -- 表示文字列の作成
            local parts = {}
            if #servers > 0 then
              table.insert(parts, "󰒋 " .. table.concat(servers, "|"))
            end
            if #linters > 0 then
              table.insert(parts, "󱔗 " .. table.concat(linters, "|"))
            end

            return #parts > 0 and table.concat(parts, " ") or "󰦕 none"
          end,
          color = { fg = "#7aa2f7" },
          separator = { left = "", right = "" },
        },

        {
          -- フォーマッタ情報を取得する関数
          function()
            local conform = require("conform")
            local formatters = conform.list_formatters(0) -- 現在のバッファのフォーマッタを取得
            if #formatters == 0 then
              return ""
            end

            local active_formatters = {}
            for _, fmt in ipairs(formatters) do
              -- ready（利用可能）なものだけを表示候補にする
              if fmt.available then
                table.insert(active_formatters, fmt.name)
              end
            end

            if #active_formatters == 0 then
              return ""
            end

            -- stop_after_first が効いている場合、実際に動くのは先頭の1つ
            -- 分かりやすくするために "󰉼 " アイコンを付ける
            return "󰉼 " .. active_formatters[1]
          end,
          color = { fg = "#ff9e64" }, -- 色はお好みで（これはオレンジ系）
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
        middle_mouse_command = function(n)
          Snacks.bufdelete(n)
        end,
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
    "tadaa/vimade",
    event = "VeryLazy",
    opts = function(_, opts)
      opts.recipe = { "default", { animate = true } }
      opts.fadelevel = 0.7
    end,
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
    dependencies = {
      "lewis6991/gitsigns.nvim",
      -- search はごてごてするのでやめた
    },
    config = function()
      require("scrollbar").setup({
        handlers = {
          cursor = true,
          diagnostic = true,
          gitsigns = true, -- Requires gitsigns
          handle = true,
          search = false, -- Requires hlslens
          ale = false, -- Requires ALE
        },
      })
    end,
  },

  -- 関数を sticky にする
  {
    "nvim-treesitter/nvim-treesitter-context",
    opts = {
      enable = true, -- Enable this plugin (Can be enabled/disabled later via commands)
      multiwindow = false, -- Enable multiwindow support.
      max_lines = 0, -- How many lines the window should span. Values <= 0 mean no limit.
      min_window_height = 0, -- Minimum editor window height to enable context. Values <= 0 mean no limit.
      line_numbers = true,
      multiline_threshold = 1, -- Maximum number of lines to show for a single context
      trim_scope = "outer", -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
      mode = "topline", -- Line used to calculate context. Choices: 'cursor', 'topline'
      -- Separator between context and content. Should be a single character string, like '-'.
      -- When separator is set, the context will only show up when there are at least 2 lines above cursorline.
      separator = nil,
      zindex = 20, -- The Z-index of the context window
      on_attach = nil, -- (fun(buf: integer): boolean) return false to disable attaching
    },
  },

  -- パンくずリスト
  {
    "Bekaboo/dropbar.nvim",
    dependencies = {
      "nvim-telescope/telescope-fzf-native.nvim",
      build = "make",
    },
    opts = {},
  },

  -- カーソル位置の移動を強調
  {
    "sphamba/smear-cursor.nvim",
    opts = {},
  },

  -- 折り畳み、LSPの診断結果、Gitなどの情報を表示する
  {
    "luukvbaal/statuscol.nvim",
    dependencies = {
      "lewis6991/gitsigns.nvim",
    },
    config = function()
      local builtin = require("statuscol.builtin")
      require("statuscol").setup({
        -- configuration goes here, for example:
        bt_ignore = { "terminal", "nofile", "ddu-ff", "ddu-ff-filter" },
        segments = {
          -- v:lua.<関数名> = Neovim の statuscolumn 用クリックハンドラ
          {
            sign = { namespace = { "diagnostic" } },
            click = "v:lua.ScSa", -- Sign action
            -- Left   - Open diagnostic float
            -- Middle - Select available code action
          },
          {
            text = { builtin.lnumfunc },
            click = "v:lua.ScLa", -- Line action
            -- Left     - Toggle DAP breakpoint
            -- <C-Left> - Toggle DAP conditional breakpoint
            -- Right    - Yank line
            -- Right    - Paste line
            -- Right x2 - Delete line
          },
          { text = { " " } },
          {
            sign = { namespace = { "gitsigns" } },
            click = "v:lua.ScSa",
            -- Left   - Preview hunk
            -- Middle - Reset hunk
            -- Right  - Stage hunk
          },
          {
            text = { builtin.foldfunc },
            click = "v:lua.ScFa", -- Fold action
            -- Left      - Open fold
            -- <C-Left>  - Open fold recursively
            -- Right     - Close fold
            -- <C-Right> - Close fold recursively
            -- Middle    - Create fold in range(click twice)
          },
          { text = { " " } },
        },
      })
    end,
  },
}
