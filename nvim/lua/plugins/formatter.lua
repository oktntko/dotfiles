local M = {}
-- 頻繁なファイル探索を避けるためにキャッシュ化
M.has_config = LazyVim.memoize(function(path, patterns)
  return vim.fs.find(patterns, { path = path, upward = true, stop = vim.uv.os_homedir() })[1]
end)

return {
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      opts.formatters = opts.formatters or {}

      opts.formatters.oxfmt = {
        ---@param ctx ConformCtx
        condition = function(_, ctx)
          return M.has_config(ctx.filename, {
            ".oxfmtrc.json",
            ".oxfmtrc.jsonc",
          })
        end,
      }
      opts.formatters.prettier = {
        ---@param ctx ConformCtx
        condition = function(_, ctx)
          return M.has_config(ctx.filename, {
            ".prettierrc.json",
            ".prettierrc.yml",
            ".prettierrc.yaml",
            ".prettierrc.json5",
            ".prettierrc.js",
            "prettier.config.js",
            ".prettierrc.ts",
            "prettier.config.ts",
            ".prettierrc.mjs",
            "prettier.config.mjs",
            ".prettierrc.mts",
            ".prettierrc.cjs",
            "prettier.config.cjs",
            ".prettierrc.cts",
            ".prettierrc.toml",
          })
        end,
      }

      opts.formatters_by_ft = opts.formatters_by_ft or {}

      local supported_fts = {
        "javascript",
        "javascriptreact",
        "typescript",
        "typescriptreact",
        "json",
        "jsonc",
        "json5",
        "yaml",
        "toml",
        "html",
        "vue",
        "css",
        "scss",
        "less",
        "markdown",
        "markdown.mdx",
        "graphql",
      }

      for _, ft in ipairs(supported_fts) do
        -- ここを単純なリストにし、下の stop_after_first で制御します
        opts.formatters_by_ft[ft] = { "oxfmt", "prettier" }
      end

      -- 「最初に見つかったもの（条件を満たしたもの）だけ実行」する設定
      opts.default_format_opts = {
        stop_after_first = true,
      }

      opts.log_level = vim.log.levels.DEBUG
    end,
  },
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = { "oxfmt", "prettier" },
    },
  },
}
