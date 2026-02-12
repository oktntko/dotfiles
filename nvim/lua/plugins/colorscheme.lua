return {
  {
    "navarasu/onedark.nvim",
    priority = 1000, -- colorscheme は最優先で読み込む
    config = function()
      require("onedark").setup({
        style = "cool",
      })
      require("onedark").load()
    end,
  },
}
