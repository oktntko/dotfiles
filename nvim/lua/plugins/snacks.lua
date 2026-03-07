local util_keys = require("util.keys")

local M = {}

M.open_split_panel = function(side) -- cmd = "vsplit"/"split", side = "left"/"right"/"top"/"bottom"
  return function(_, item)
    local function open_item()
      if item.buf then
        vim.api.nvim_set_current_buf(item.buf)
      elseif item.file then
        vim.cmd("edit " .. vim.fn.fnameescape(item.file))
      elseif item.path then
        vim.cmd("edit " .. vim.fn.fnameescape(item.path))
      end
    end

    util_keys.smart_split(side, open_item)
  end
end

return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  keys = {
    {
      "<Tab>",
      function()
        Snacks.picker.buffers()
      end,
      mode = { "n" },
      desc = "Buffers",
    },
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
    {
      "<C-S-w>",
      function()
        Snacks.bufdelete()
      end,
      desc = "Delete Buffer",
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
    scroll = {
      animate = {
        duration = { step = 10, total = 100 }, -- Reduce these values for faster scroll
        easing = "linear",
      },
      animate_repeat = {
        delay = 50, -- Delay before repeating
        duration = { step = 3, total = 40 }, -- Faster speed when repeating
        easing = "linear",
      },
    },
    picker = {
      actions = {
        open_split_left = M.open_split_panel("left"),
        open_split_right = M.open_split_panel("right"),
      },
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
            ["<PageDown>"] = { "list_scroll_down", mode = { "n", "i" } },
            ["<PageUp>"] = { "list_scroll_up", mode = { "n", "i" } },
            ["<C-Home>"] = { "list_top", mode = { "n", "i" } },
            ["<C-End>"] = { "list_bottom", mode = { "n", "i" } },
            ["<Tab>"] = { "list_down", mode = { "n", "i" } },
            ["<S-Tab>"] = { "list_up", mode = { "n", "i" } },
            ["<C-Tab>"] = { "select_and_next", mode = { "n", "i" } },
            ["<C-S-Tab>"] = { "select_and_prev", mode = { "n", "i" } },
          },
        },
        list = {
          keys = {
            ["<PageDown>"] = { "list_scroll_down", mode = { "n", "i" } },
            ["<PageUp>"] = { "list_scroll_up", mode = { "n", "i" } },
            ["<C-Home>"] = { "list_top", mode = { "n", "i" } },
            ["<C-End>"] = { "list_bottom", mode = { "n", "i" } },
            ["<Tab>"] = { "list_down", mode = { "n", "i" } },
            ["<S-Tab>"] = { "list_up", mode = { "n", "i" } },
            ["<C-Tab>"] = { "select_and_next", mode = { "n", "i" } },
            ["<C-S-Tab>"] = { "select_and_prev", mode = { "n", "i" } },
          },
        },
      },

      sources = {
        buffers = {
          win = {
            input = {
              keys = {
                ["<C-x>"] = { "bufdelete", mode = { "n", "i" } },
                -- 開き方工夫
                ["<C-k>"] = { "open_split_left", mode = { "n", "i" } },
                ["<C-l>"] = { "open_split_right", mode = { "n", "i" } },
              },
            },
            list = {
              keys = {
                ["<C-x>"] = { "bufdelete", mode = { "n", "i" } },
                -- 開き方工夫
                ["<C-k>"] = { "open_split_left", mode = { "n", "i" } },
                ["<C-l>"] = { "open_split_right", mode = { "n", "i" } },
              },
            },
          },
        },

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
            explorer_filename_yank = function(picker, item, action)
              if not item then
                return
              end
              local name = vim.fn.fnamemodify(item.file, ":t")
              vim.fn.setreg("+", name)
              vim.notify(string.format("%s yanked", name))
            end,
            explorer_relative_yank = function(picker, item, action)
              if not item then
                return
              end
              local name = vim.fn.fnamemodify(item.file, ":.")
              vim.fn.setreg("+", name)
              vim.notify(string.format("%s yanked", name))
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

                -- ファイル名コピー
                ["y"] = "explorer_filename_yank",
                ["Y"] = "explorer_relative_yank",

                -- 開き方工夫
                ["<C-k>"] = { "open_split_left", mode = { "n", "v" } },
                ["<C-l>"] = { "open_split_right", mode = { "n", "v" } },
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

      formatters = {
        file = {
          filename_first = true, -- display filename before the file path
          --- * left: truncate the beginning of the path
          --- * center: truncate the middle of the path
          --- * right: truncate the end of the path
          ---@type "left"|"center"|"right"
          truncate = "center",
          min_width = 40, -- minimum length of the truncated path
          filename_only = false, -- only show the filename
          icon_width = 2, -- width of the icon (in characters)
          git_status_hl = true, -- use the git status highlight group for the filename
        },
      },
    },
    terminal = {
      win = { style = "float" },
    },
  },
}
