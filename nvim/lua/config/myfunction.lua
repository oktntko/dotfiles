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

function M.toggle_diffview(diffviewCmd)
  local lib = require("diffview.lib")
  local view = lib.get_current_view()

  if view then
    -- 現在のタブがDiffview専用タブの場合

    -- 1. 避難: Diffviewを閉じる際のエラーを防ぐため、一度別のタブへ移動を試みる
    -- (現在のタブがDiffview専用タブの場合、tabcloseが失敗しやすいため)
    vim.cmd("silent! tabprevious")

    -- 2. 実行: エラーが起きても後続の処理を止めないよう pcall で実行
    local success, err = pcall(function()
      view:close()
    end)

    -- 3. 強制解除: もしエラーが出ても、Diffviewの内部状態をリセットしやすくする
    if not success then
      -- それでもダメな場合は、コマンドで強制的に閉じる
      vim.cmd(diffviewCmd)
    end
  else
    -- 現在のタブがDiffview でない場合
    local all_views = lib.views
    local target_view = all_views[1]

    if target_view and target_view.tabpage and vim.api.nvim_tabpage_is_valid(target_view.tabpage) then
      -- 最初に見つかった View を再利用することで、タブが増殖するのを防ぐ
      -- 既存のタブがあれば、そこへジャンプ
      vim.api.nvim_set_current_tabpage(target_view.tabpage)
    else
      -- どこにもなければ新しく開く
      vim.cmd(diffviewCmd)
    end
  end
end

return M
