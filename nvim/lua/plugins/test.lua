return {
  {
    "nvim-neotest/neotest",
    opts = function(_, opts)
      opts.log_level = vim.log.levels.INFO
      table.insert(opts.adapters, require("my-neotest-vitest"))
    end,
  },
}
