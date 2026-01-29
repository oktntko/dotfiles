local M = {}

-- Toggle Snacks Explorer
function M.toggle_explorer()
  -- snacks_picker_list は単なる buffer / window であって、専用の「toggle コマンド」は無い
  -- その buffer があれば閉じる、なければ開く 自前トグル処理
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.bo[buf].filetype == "snacks_picker_list" then
      vim.api.nvim_win_close(win, true)
      return
    end
  end

  Snacks.explorer()
end

return M
