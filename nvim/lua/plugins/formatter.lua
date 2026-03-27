return {
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = { "oxfmt" },
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
  {
    "neovim/nvim-lspconfig",
    opts = {
      ensure_installed = { "oxfmt", "prettier" },
    },
  },
}
