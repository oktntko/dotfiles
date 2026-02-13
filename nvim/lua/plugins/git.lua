return {
  {
    "sindrets/diffview.nvim",
    keys = {
      { "<leader>gg", "<cmd>DiffviewFileHistory<cr>", mode = { "n" }, desc = "Diffview: Repo history" },
      { "<leader>gH", "<cmd>DiffviewFileHistory %<cr>", mode = { "n" }, desc = "Diffview: Current file history" },
    },
    opts = function()
      local actions = require("diffview.actions")

      return {
        enhanced_diff_hl = true, -- 行内の詳細な差分ハイライトを有効化

        file_panel = {
          win_config = { -- See |diffview-config-win_config|
            position = "left",
            width = 40,
            win_opts = {},
          },
        },

        keymaps = {
          view = {
            { "n", "e", actions.goto_file_edit, { desc = "Open the file in the previous tabpage" } },
          },
          file_panel = {
            { "n", "e", actions.goto_file_edit, { desc = "Open the file in the previous tabpage" } },
          },
          file_history_panel = {
            { "n", "e", actions.goto_file_edit, { desc = "Open the file in the previous tabpage" } },
          },
        },
      }
    end,
  },
  {
    "lewis6991/gitsigns.nvim",
    opts = {},
  },
}
