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
    vim.fn.jobstart({
      python,
      "-m",
      "IPython",
      "--no-confirm-exit",
      "--InteractiveShell.separate_in=",
      "--InteractiveShell.separate_out=",
      "--InteractiveShell.separate_out2=",
    }, { term = true, cwd = cwd })
  end

  -- 每个 Python 文件连接到同一个持续运行的 IPython 会话。
  vim.b[source_buf].slime_config = { jobid = vim.b[repl_buf].terminal_job_id }
  vim.api.nvim_set_current_win(source_win)
end

local function cell_marker(line)
  return line:match("^# %%%%") ~= nil
end

local function run_cell()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local row = vim.api.nvim_win_get_cursor(0)[1]
  local first = row
  while first > 1 and not cell_marker(lines[first]) do
    first = first - 1
  end
  if cell_marker(lines[first]) then
    if lines[first]:find("[markdown]", 1, true) or lines[first]:find("[raw]", 1, true) then
      vim.notify("当前是说明单元格，无需执行")
      return
    end
    first = first + 1
  end
  local last = first
  while last <= #lines and not cell_marker(lines[last]) do
    last = last + 1
  end
  local code = table.concat(vim.list_slice(lines, first, last - 1), "\n")
  if not code:match("%S") then
    return
  end
  open_ipython()
  if repl_buf and vim.api.nvim_buf_is_valid(repl_buf) and vim.b.slime_config then
    local source_buf = vim.api.nvim_get_current_buf()
    local target_buf = repl_buf
    local attempts = 0
    -- 第一次启动需要等 IPython 就绪，否则启动阶段会吞掉发送的代码。
    local function send_when_ready()
      if not vim.api.nvim_buf_is_valid(source_buf) or not vim.api.nvim_buf_is_valid(target_buf) then
        return
      end
      local output = table.concat(vim.api.nvim_buf_get_lines(target_buf, 0, -1, false), "\n")
      if output:match("In %[%d+%]:") then
        vim.api.nvim_buf_call(source_buf, function()
          vim.fn["slime#send"](code .. "\n")
        end)
      elseif attempts < 100 then
        attempts = attempts + 1
        vim.defer_fn(send_when_ready, 100)
      else
        vim.notify("IPython 未就绪，请检查底部终端后重试", vim.log.levels.ERROR)
      end
    end
    send_when_ready()
  end
end

return {
  "jpalardy/vim-slime",
  ft = "python",
  init = function()
    vim.g.slime_target = "neovim"
    vim.g.slime_no_mappings = 1
    -- 使用 IPython 原生的括号粘贴，避免每次发送都显示 %cpaste / --。
    vim.g.slime_python_ipython = 0
    vim.g.slime_bracketed_paste = 1
    vim.g.slime_menu_config = 1
    vim.cmd([[
      function! SlimeOverride_EscapeText_python(text) abort
        let text = substitute(a:text, '\r\n', "\n", 'g')
        " 保留代码内部的空行和缩进；末尾一个换行结束代码块，另一个在粘贴结束后提交。
        return substitute(text, '\n\+$', '', '') . "\n\n"
      endfunction
    ]])
  end,
  config = function()
    vim.keymap.set("n", "<leader>jc", run_cell, { desc = "执行当前 Notebook 单元格" })
    vim.keymap.set("n", "]j", function()
      vim.fn.search("^# %%", "W")
    end, { desc = "下一个 Notebook 单元格" })
    vim.keymap.set("n", "[j", function()
      vim.fn.search("^# %%", "bW")
    end, { desc = "上一个 Notebook 单元格" })
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
