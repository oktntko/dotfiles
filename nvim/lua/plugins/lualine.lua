return {
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = function(_, opts)
      opts.sections.lualine_x = {
        -- 1. ファイルタイプ (例: typescript, lua, python)
        {
          "filetype",
          icon_only = false, -- アイコンだけでなく名前も出す
          separator = { left = "", right = "" },
          color = { fg = "#ff9e64", gui = "bold" },
          on_click = function()
            LazyVim.format.info()
          end,
        },

        -- 2. LSPサーバー名
        {
          function()
            -- 1. 特殊なバッファ（ピッカー等）なら何も出さない
            local buftype = vim.api.nvim_get_option_value("buftype", { buf = 0 })
            if buftype ~= "" then return "" end

            -- 2. バッファの作成時刻を記録（なければ現在の時刻をセット）
            local buf = vim.api.nvim_get_current_buf()
            local now = vim.loop.now() -- ミリ秒単位

            -- バッファごとの初回アクセス時刻を保持する変数がなければ初期化
            if not vim.b[buf].opened_at then
              vim.b[buf].opened_at = now
            end

            -- 3. LSPクライアントの取得
            local clients = vim.lsp.get_clients({ bufnr = 0 })

            -- LSPが見つかった場合は即座に表示
            if next(clients) ~= nil then
              local client_names = {}
              for _, client in ipairs(clients) do
                table.insert(client_names, client.name)
              end
              return " " .. table.concat(client_names, "|")
            end

            -- 4. LSPが見つからない場合、経過時間をチェック
            local elapsed = now - vim.b[buf].opened_at

            if elapsed < 250 then
              -- 0.25秒（250ms）以内なら「ロード中」扱いにして No LSP を隠す
              return "󱑮 Loading..."
            else
              -- 0.25秒経ってもLSPがいなければ、本当にLSPがないと判断
              return "No LSP"
            end
          end,
          color = { fg = "#7aa2f7", gui = "bold" },
          separator = { left = "", right = "" },
        },
      }
    end,
  },
}
