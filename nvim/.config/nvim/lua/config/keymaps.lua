-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua

-- 运行python文件的快捷键
vim.keymap.set("n", "<leader>rp", function()
  if vim.bo.filetype ~= "python" then
    vim.notify("当前文件不是 Python 文件")
    return
  end

  vim.cmd("write")
  local file = vim.api.nvim_buf_get_name(0)

  Snacks.terminal.open({ "python", file }, {
    cwd = vim.fn.fnamemodify(file, ":h"),
    auto_close = false,
    win = {
      position = "bottom",
      height = 0.35,
    },
  })
end, { desc = "Run Python File" })
