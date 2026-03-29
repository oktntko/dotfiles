return {
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = { "oxfmt", "prettier" },
    },
  },

  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        javascript = { "oxfmt" },
        typescript = { "oxfmt" },
        javascriptreact = { "oxfmt" },
        typescriptreact = { "oxfmt" },
        json = { "oxfmt" },
        vue = { "prettier" },
      },
    },
  },
  {
    "nvim-mini/mini.icons",
    opts = {
      file = {
        [".oxfmtrc.json"] = { glyph = "", hl = "MiniIconsCyan" },
        [".oxfmtrc.jsonc"] = { glyph = "", hl = "MiniIconsCyan" },
        ["oxfmt.config.ts"] = { glyph = "", hl = "MiniIconsCyan" },
      },
    },
  },
}
