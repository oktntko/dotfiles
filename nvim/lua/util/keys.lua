local M = {}

-- Toggle Snacks Explorer
function M.toggle_explorer()
  -- snacks_picker_list は単なる buffer / window であって、専用の「toggle コマンド」は無い
  -- その buffer があれば閉じる、なければ開く 自前トグル処理
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.bo[buf].filetype == "snacks_layout_box" then
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
    local success = pcall(function()
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

function M.smart_split(
  side --[[ "left" or "right" ]],
  callback_open_function
)
  local TYPE, CONTENTS = 1, 2

  local function is_explorer(winid)
    if not vim.api.nvim_win_is_valid(winid) then
      return false
    end

    return vim.bo[vim.api.nvim_win_get_buf(winid)].filetype == "snacks_layout_box"
  end

  local function find_editor_winid_list(node_list)
    local file_winid_list = {}

    -- 1. 直下の leaf を収集し、非エクスプローラが含まれるか判定
    for _, node in ipairs(node_list) do
      if node[TYPE] == "leaf" then
        local winid = node[CONTENTS]
        if not is_explorer(winid) then
          table.insert(file_winid_list, winid)
        end
      end
    end

    -- 非エクスプローラが1つでもあれば、収集した ID リスト（エクスプローラ抜き）を返す
    if #file_winid_list > 0 then
      return file_winid_list
    end

    -- 2. 直下になければ、子のノード (row/col) を再帰的に探索
    for _, node in ipairs(node_list) do
      if node[TYPE] ~= "leaf" then
        file_winid_list = find_editor_winid_list(node[CONTENTS])
        if #file_winid_list > 0 then
          return file_winid_list
        end
      end
    end

    return {}
  end

  local layout = vim.fn.winlayout()

  local editor_winid_list = layout[TYPE] == "leaf"
      and (not is_explorer(layout[CONTENTS]) and { layout[CONTENTS] } or {})
    or find_editor_winid_list(layout[CONTENTS])

  if #editor_winid_list == 0 then
    return -- 何も見つからなかったら何もしない
  end

  if #editor_winid_list == 1 then
    -- まだ分割されていなかったら分割する
    local winid = editor_winid_list[1]
    vim.api.nvim_set_current_win(winid)
    vim.cmd("vsplit")
    if side == "left" then
      vim.cmd("wincmd h")
    end
  else
    -- すでに分割されていたら、そのパネルに開く
    local winid = side == "left" and editor_winid_list[1] or editor_winid_list[#editor_winid_list]
    vim.api.nvim_set_current_win(winid)
  end

  callback_open_function()
end

return M
