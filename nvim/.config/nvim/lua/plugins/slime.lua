local repl_buf

local function open_ipython()
  local source_buf = vim.api.nvim_get_current_buf()
  local source_win = vim.api.nvim_get_current_win()

  if
    repl_buf
    and vim.api.nvim_buf_is_valid(repl_buf)
    and vim.fn.jobwait({ vim.b[repl_buf].terminal_job_id }, 0)[1] == -1
  then
    local wins = vim.fn.win_findbuf(repl_buf)
    if #wins == 0 then
      vim.cmd("botright horizontal 12split")
      vim.api.nvim_win_set_buf(0, repl_buf)
    else
      vim.api.nvim_win_call(wins[1], function()
        vim.cmd("wincmd J")
        vim.cmd("resize 12")
      end)
    end
  else
    local python = vim.fn.exepath("python")
    local ok, selector = pcall(require, "venv-selector")
    if ok then
      python = selector.python() or python
    end
    if python == "" then
      vim.notify("没有找到 Python，请先激活环境或使用 VenvSelect", vim.log.levels.ERROR)
      return
    end

    local file = vim.api.nvim_buf_get_name(source_buf)
    local cwd = file ~= "" and vim.fn.fnamemodify(file, ":h") or vim.fn.getcwd()
    vim.cmd("botright horizontal 12new")
    repl_buf = vim.api.nvim_get_current_buf()
    vim.bo.bufhidden = "hide"
    vim.fn.jobstart({ python, "-m", "IPython", "--no-confirm-exit" }, { term = true, cwd = cwd })
  end

  -- 每个 Python 文件连接到同一个持续运行的 IPython 会话。
  vim.b[source_buf].slime_config = { jobid = vim.b[repl_buf].terminal_job_id }
  vim.api.nvim_set_current_win(source_win)
end

return {
  "jpalardy/vim-slime",
  ft = "python",
  init = function()
    vim.g.slime_target = "neovim"
    vim.g.slime_no_mappings = 1
    vim.g.slime_python_ipython = 1
    vim.g.slime_menu_config = 1
  end,
  config = function()
    vim.keymap.set("n", "<leader>ji", open_ipython, { desc = "打开/连接底部 IPython" })
    vim.keymap.set("n", "<leader>jl", "<Plug>SlimeLineSend", { remap = true, desc = "发送当前行到 IPython" })
    vim.keymap.set(
      "n",
      "<leader>jb",
      "<Plug>SlimeParagraphSend",
      { remap = true, desc = "发送当前段落到 IPython" }
    )
    vim.keymap.set("x", "<leader>jr", "<Plug>SlimeRegionSend", { remap = true, desc = "发送选中代码到 IPython" })
  end,
}
