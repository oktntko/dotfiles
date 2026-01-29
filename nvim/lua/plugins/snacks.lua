return {
  "folke/snacks.nvim",
  opts = {
    picker = {
      sources = {
        explorer = {
          hidden = true,
          win = {
            input = {
              keys = {
                -- Disable Esc in normal mode to prevent accidental closing
                ["<Esc>"] = { "<Nop>", mode = { "n" } },
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
