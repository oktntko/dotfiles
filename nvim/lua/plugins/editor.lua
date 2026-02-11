return {
  {
    "numToStr/Comment.nvim",
    keys = {
      { "gc", mode = { "n", "x" } },
      { "gb", mode = { "n", "x" } },
      { "gcc", mode = "n" },
    },
    config = function()
      ---@diagnostic disable-next-line: missing-fields
      require("Comment").setup({
        pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
      })
    end,
  },
  {
    "JoosepAlviste/nvim-ts-context-commentstring",
    config = function()
      require("ts_context_commentstring").setup({
        enable_autocmd = false,
      })
    end,
  },
}
