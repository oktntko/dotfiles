return {
  "saghen/blink.cmp",
  opts = {
    keymap = {
      preset = "enter", -- Enterで確定する基本スタイル

      -- Tabでメニューの最初の項目を選択し、次へと進む設定
      ["<Tab>"] = { "select_next", "fallback" },
      ["<S-Tab>"] = { "select_prev", "fallback" },
    },
    completion = {
      list = {
        selection = {
          -- ここを 'preselect' にすると、メニューが出た瞬間に1番目が選択状態になります
          -- 'manual' だと、Tabを1回叩いた時に1番目が選択されます
          preselect = false,
          auto_insert = true,
        },
      },
    },
  },
}
