local util_keys = require("util.keys")

return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  keys = {
    {
      "<C-e>",
      function()
        util_keys.toggle_explorer()
      end,
      mode = { "n", "v" },
      desc = "Toggle Snacks Explorer",
    },
    {
      "<C-t>",
      function()
        Snacks.terminal()
      end,
      mode = { "n", "v", "t" },
      desc = "Terminal (Root Dir)",
    },
    {
      "<C-S-f>",
      function()
        Snacks.picker.grep()
      end,
      mode = { "n", "v" },
      desc = "Grep",
    },
    {
      "<C-p>",
      function()
        Snacks.picker.files()
      end,
      mode = { "n", "v" },
      desc = "Find Files",
    },
  },
  opts = {
    indent = {
      chunk = {
        enabled = true,
        char = {
          corner_top = "╭",
          corner_bottom = "╰",
          arrow = "",
        },
      },
    },
    picker = {
      win = {
        input = {
          keys = {
            -- Snacksが <C-r>にショートカットを設定しているため、クリップボードの中身を直接挿入する
            ["<C-v>"] = {
              function()
                local text = vim.fn.getreg("+")
                -- 改行が含まれると入力が壊れることがあるので除去、またはスペースに置換
                text = text:gsub("\n", " ")
                vim.api.nvim_put({ text }, "c", true, true)
              end,
              mode = { "i", "n" },
              desc = "Paste from clipboard",
            },
          },
        },
      },

      sources = {
        explorer = {
          hidden = true,
          actions = {
            -- 閉じているディレクトリなら開く、 開いているディレクトリ・ファイルなら下に移動
            expand_or_list_down = function(picker, item, action)
              if not item then
                return
              end

              if item.dir and not item.open then
                -- dir & closed → 展開
                local Actions = require("snacks.explorer.actions").actions
                Actions.confirm(picker, item, action)
                return
              end

              -- dir & open or file → 下へ
              local Actions = require("snacks.picker.actions")
              Actions.list_down(picker)
            end,

            -- 開いているディレクトリなら閉じる、 閉じているディレクトリ・ファイルなら親ディレクトリに移動
            collapse_or_up_to_parent = function(picker, item, action)
              if not item then
                return
              end

              if item.dir and item.open then
                -- dir & open → たたむ
                local Actions = require("snacks.explorer.actions").actions
                Actions.confirm(picker, item, action)
                return
              end

              -- dir & closed or file → 親 dir に移動
              -- 親 dir がなければ終了
              if not item.parent then
                return
              end

              local Actions = require("snacks.explorer.actions")
              Actions.update(picker, { target = item.parent.file, refresh = true })
            end,
          },
          win = {
            input = {
              keys = {
                -- "<Nop>" だと input にフォーカスが残るため。
                ["<Esc>"] = { "focus_list", mode = { "i" } },
                ["<C-f>"] = { "focus_list", mode = { "i" } },
              },
            },
            list = {
              keys = {
                -- Disable Esc in normal mode to prevent accidental closing
                ["<Esc>"] = { "<Nop>", mode = { "n" } },
                ["<C-e>"] = {
                  function()
                    util_keys.toggle_explorer()
                  end,
                  mode = { "n", "v" },
                  desc = "Toggle Snacks Explorer",
                },
                ["<C-t>"] = {
                  function()
                    Snacks.terminal()
                  end,
                  mode = { "n", "v", "t" },
                  desc = "Terminal (Root Dir)",
                },
                ["<C-g>"] = {
                  function()
                    util_keys.toggle_diffview("DiffviewOpen")
                  end,
                  mode = { "n", "v" },
                  desc = "Toggle Diffview",
                },
                ["<C-S-g>"] = {
                  function()
                    util_keys.toggle_diffview("DiffviewFileHistory")
                  end,
                  mode = { "n", "v" },
                  desc = "Toggle Diffview: Repo history",
                },
                ["<C-f>"] = {
                  "focus_input",
                  mode = { "n", "v" },
                  desc = "Search",
                },
                ["<C-S-f>"] = {
                  function()
                    Snacks.picker.grep()
                  end,
                  mode = { "n", "v" },
                  desc = "Grep",
                },
                ["<C-p>"] = {
                  function()
                    Snacks.picker.files()
                  end,
                  mode = { "n", "v" },
                  desc = "Find Files",
                },
                ["<Right>"] = "expand_or_list_down",
                ["<Left>"] = "collapse_or_up_to_parent",
              },
            },
          },
          matcher = {
            fuzzy = true,
          },
        },

        lines = {
          layout = {
            preset = "vscode", -- レイアウトをコンパクトにする
            preview = false, -- プレビューを消して視覚ノイズを減らす
          },
        },
      },
    },
    terminal = {
      win = { style = "float" },
    },
  },
}
