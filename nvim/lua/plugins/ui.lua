return {
  -- colorscheme
  -- {
  --   "folke/tokyonight.nvim",
  --   lazy = false,
  --   priority = 1000,
  --   opts = function(_, opts)
  --     opts.dim_inactive = true -- dims inactive windows
  --     opts.lualine_bold = true -- When `true`, section headers in the lualine theme will be bold
  --     opts.on_highlights = function(hl)
  --       hl.WinSeparator = { fg = "#35363e" }
  --     end
  --   end,
  -- },
  {
    "bluz71/vim-nightfly-colors",
    lazy = false,
    priority = 1000,
    config = function()
      -- Lua initialization file
      vim.g.nightflyCursorColor = true
      -- Lua initialization file
      vim.g.nightflyNormalPmenu = true
      -- -- Lua initialization file
      vim.g.nightflyNormalFloat = true
      vim.o.winborder = "single"
      -- -- Lua initialization file
      -- vim.g.nightflyTransparent = true
      -- Lua initialization file
      vim.g.nightflyUnderlineMatchParen = true
      -- Lua initialization file
      vim.g.nightflyVirtualTextColor = true

      require("nightfly").custom_colors({
        blue = "#33adff",
      })
      -- Lua initialization file
      local custom_highlight = vim.api.nvim_create_augroup("CustomHighlight", {})
      vim.api.nvim_create_autocmd("ColorScheme", {
        pattern = "nightfly",
        callback = function()
          local highlight = vim.api.nvim_set_hl

          -- snacks picker
          highlight(0, "SnacksPickerGitStatusAdded", { fg = "#a1cd5e" }) -- 緑色
          highlight(0, "SnacksPickerGitStatusModified", { fg = "#e3d18a" }) -- 黄色
          highlight(0, "SnacksPickerGitStatusRenamed", { fg = "#7ed491" }) -- 黄色
          highlight(0, "SnacksPickerGitStatusUntracked", { fg = "#c792ea" }) -- 紫色
        end,
        group = custom_highlight,
      })

      vim.cmd([[colorscheme nightfly]])
    end,
  },
  {
    "akinsho/bufferline.nvim",
    enabled = false,
  },
  {
    "mawkler/modicator.nvim",
    event = "VeryLazy",
    opts = {
      highlights = {
        defaults = { bold = true },
        use_cursorline_background = true,
      },
    },
  },
  {
    -- tabpage
    "crispgm/nvim-tabline",
    event = "VeryLazy",
    config = true,
  },

  -- 下のライン
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

  -- 右上のやつ
  {
    "b0o/incline.nvim",
    event = "VeryLazy",
    opts = function()
      return {
        window = {
          padding = 0,
          margin = { horizontal = 0 },
        },
        render = function(props)
          local buf = props.buf
          local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ":t")

          if filename == "" then
            filename = "[No Name]"
          end

          local devicons = require("nvim-web-devicons")
          local extension = vim.fn.fnamemodify(filename, ":e")
          local icon, icon_hl = devicons.get_icon(filename, extension, { default = true })

          local modified = vim.bo[buf].modified

          -------------------------------------------------
          -- 🟢 未保存マーク
          -------------------------------------------------
          local modified_icon = modified and "● " or ""

          -------------------------------------------------
          --  Git差分（gitsigns）
          -------------------------------------------------
          local git = vim.b[buf].gitsigns_status_dict
          local git_component = {}

          if git then
            local added = git.added or 0
            local changed = git.changed or 0
            local removed = git.removed or 0

            if added > 0 then
              table.insert(git_component, {
                " " .. added .. " ",
                guifg = "#2ea043", -- VSCodeっぽい緑
              })
            end
            if changed > 0 then
              table.insert(git_component, {
                " " .. changed .. " ",
                guifg = "#e3b341", -- VSCodeっぽい黄色
              })
            end
            if removed > 0 then
              table.insert(git_component, {
                " " .. removed .. " ",
                guifg = "#f85149", -- VSCodeっぽい赤
              })
            end
          end

          -------------------------------------------------
          -- ⚠ 診断情報（LSP）
          -------------------------------------------------
          local diagnostics = vim.diagnostic.count(buf)

          local diag_component = {}

          -- ❌ Error（赤）
          if diagnostics[vim.diagnostic.severity.ERROR] then
            table.insert(diag_component, {
              " " .. diagnostics[vim.diagnostic.severity.ERROR] .. " ",
              guifg = "#f85149", -- VSCode red
            })
          end

          -- ⚠ Warning（黄色）
          if diagnostics[vim.diagnostic.severity.WARN] then
            table.insert(diag_component, {
              " " .. diagnostics[vim.diagnostic.severity.WARN] .. " ",
              guifg = "#e3b341", -- VSCode yellow
            })
          end

          -- ℹ Info（青）
          if diagnostics[vim.diagnostic.severity.INFO] then
            table.insert(diag_component, {
              " " .. diagnostics[vim.diagnostic.severity.INFO] .. " ",
              guifg = "#58a6ff", -- VSCode blue
            })
          end

          -- 💡 Hint（グレー）
          if diagnostics[vim.diagnostic.severity.HINT] then
            table.insert(diag_component, {
              "󰛩 " .. diagnostics[vim.diagnostic.severity.HINT] .. " ",
              guifg = "#8b949e", -- VSCode gray
            })
          end

          local result = {}
          -- 🟢 未保存
          table.insert(result, {
            modified_icon,
            guifg = modified and "#2ea043" or nil,
          })

          if icon then
            table.insert(result, {
              icon .. " ",
              group = icon_hl,
            })
          end

          -- ファイル名
          table.insert(result, {
            filename,
            gui = modified and "bold,italic" or "bold",
          })

          --  Git差分
          if #git_component > 0 then
            table.insert(result, {
              " ┊ ",
            })
          end
          for _, item in ipairs(git_component) do
            table.insert(result, item)
          end

          -- 診断
          if #diag_component > 0 then
            table.insert(result, {
              " ┊ ",
            })
          end
          for _, item in ipairs(diag_component) do
            table.insert(result, item)
          end

          return result
        end,
      }
    end,
  },

  {
    "hedyhli/outline.nvim",
    event = "VeryLazy",
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
    event = "VeryLazy",
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
    event = "VeryLazy",
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
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    event = "VeryLazy",
  },

  -- パンくずリスト
  {
    "Bekaboo/dropbar.nvim",
    event = "VeryLazy",
    dependencies = {
      "nvim-telescope/telescope-fzf-native.nvim",
      build = "make",
    },
    opts = {},
  },

  -- 折り畳み、LSPの診断結果、Gitなどの情報を表示する
  {
    "luukvbaal/statuscol.nvim",
    event = "VeryLazy",
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
