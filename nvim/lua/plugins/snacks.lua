-- https://github.com/folke/snacks.nvim
-- lua/snacks/picker/source/explorer.lua
---@class snacks.picker.explorer.Item: snacks.picker.finder.Item
---@field file string
---@field dir? boolean
---@field parent? snacks.picker.explorer.Item
---@field open? boolean
---@field last? boolean
---@field sort? string
---@field internal? boolean internal parent directories not part of fd output
---@field status? string

return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  opts = {
    picker = {
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
              Actions.list_down(picker, item)
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
                -- Disable Esc in normal mode to prevent accidental closing
                ["<Esc>"] = { "<Nop>", mode = { "n" } },
                -- Add custom keymap to toggle Snacks Explorer
                ["<C-t>"] = function()
                  require("config.myfunction").toggle_explorer()
                end,
                -- Add custom keymap to toggle Snacks terminal
                ["<C-g>"] = function()
                  Snacks.terminal()
                end,
              },
            },
            list = {
              keys = {
                -- Disable Esc in normal mode to prevent accidental closing
                ["<Esc>"] = { "<Nop>", mode = { "n" } },
                -- Add custom keymap to toggle Snacks Explorer
                ["<C-t>"] = function()
                  require("config.myfunction").toggle_explorer()
                end,
                -- Add custom keymap to toggle Snacks terminal
                ["<C-g>"] = function()
                  Snacks.terminal()
                end,
                ["<Right>"] = "expand_or_list_down",
                ["<Left>"] = "collapse_or_up_to_parent",
              },
            },
          },
        },
      },
    },
    terminal = {
      win = { style = "float" },
    },
  },
}
