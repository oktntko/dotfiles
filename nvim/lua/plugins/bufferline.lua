return {
  "akinsho/bufferline.nvim",
  opts = {
    options = {
      -- 常にタブを表示する
      always_show_bufferline = true,
      -- 左クリックで buffer 切り替え（デフォルトの挙動）
      -- left_mouse_command = "buffer %d",
      -- ミドルクリックで 閉じる
      middle_mouse_command = "bdelete! %d",
      -- 右クリックで 縦分割
      right_mouse_command = "vertical sbuffer %d",
    },
  },
}
