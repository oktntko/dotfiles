local util_keys = require("util.keys")

local M = {}

M.open_split_panel = function(cmd) -- cmd = "vsplit" or "split"
  return function(picker, item, action)
    if not item then
      return
    end

    local Actions = require("snacks.explorer.actions").actions
    if item.dir then
      return Actions.confirm(picker, item, action)
    end

    -- 期待するレイアウトタイプ (vsplitならrow, splitならcol)
    -- winlayoutの 'row' は左右(vertical split)、'col' は上下(horizontal split)
    local target_layout = (cmd == "vsplit") and "row" or "col"

    -- 指定されたレイアウトが既に存在するかチェックし、末尾のウィンドウIDを返す
    local function find_target(layout, is_root)
      if layout[1] == target_layout then
        local children = layout[2]

        -- 【ここがポイント】
        -- ルート(最上位)の row なら、Explorerがいるので「3つ以上」必要。
        -- それより深い階層の row/col なら、純粋な分割なので「2つ以上」あればOK。
        local threshold = (is_root and cmd == "vsplit") and 3 or 2

        if #children >= threshold then
          local last = children[#children]
          while last[1] ~= "leaf" do
            last = last[2][#last[2]]
          end
          return last[2]
        end
      end

      if layout[1] ~= "leaf" then
        for _, child in ipairs(layout[2]) do
          -- 子要素の探索時は is_root を false にして潜る
          local found = find_target(child, false)
          if found then
            return found
          end
        end
      end
      return nil
    end

    -- 第一引数にレイアウト、第二引数に true (ルート階層) を渡す
    local target_win = find_target(vim.fn.winlayout(), true)

    if target_win then
      -- 既に分割が存在すれば、そのウィンドウに移動して開く
      vim.api.nvim_set_current_win(target_win)
      Actions.confirm(picker, item, action)
    else
      -- 分割がなければ、エクスプローラ以外の直前のウィンドウに戻って分割
      vim.cmd("wincmd p")
      vim.cmd(cmd)
      Actions.confirm(picker, item, action)
    end
  end
end

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
            open_vsplit_panel = M.open_split_panel("vsplit"),
            open_hsplit_panel = M.open_split_panel("split"),
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
                ["<RightMouse>"] = "open_vsplit_panel",
                ["<MiddleMouse>"] = "open_hsplit_panel",
                ["l"] = "open_vsplit_panel",
                ["p"] = "open_hsplit_panel",
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
