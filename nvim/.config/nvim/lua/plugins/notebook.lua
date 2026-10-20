local function default_bridge_python()
  -- 上游优先查找 python3；Windows 上可能因此误选 MSYS2 的 Python。
  -- 当前 Notebook 工作环境是 Miniforge/d2l，桥接进程也使用该环境。
  local executable = vim.fn.has("win32") == 1 and "python.exe" or "bin/python"
  local d2l = vim.fn.expand("~/miniforge3/envs/d2l/") .. executable
  if vim.fn.executable(d2l) == 1 then
    return d2l
  end
  local python = vim.fn.exepath("python")
  return python ~= "" and python or nil
end

local function start_selected_python()
  local state = require("ipynb").get_state()
  if not state then
    vim.notify("请先打开一个 Notebook", vim.log.levels.WARN)
    return
  end
  if state.kernel and state.kernel.job_id then
    vim.notify("内核已启动；切换环境后请先执行 :NotebookKernelShutdown", vim.log.levels.WARN)
    return
  end

  local ok, selector = pcall(require, "venv-selector")
  local python = ok and selector.python() or nil
  if not python or python == "" then
    vim.notify("请先使用 :VenvSelect 选择 Python 环境", vim.log.levels.WARN)
    return
  end
  require("ipynb.kernel").connect(state, { python_path = python })
end

return {
  -- 两个插件都会接管 .ipynb 的读写，必须关闭旧的文本转换方案。
  { "GCBallesteros/jupytext.nvim", enabled = false },
  {
    "ajbucci/ipynb.nvim",
    -- 在读取命令行传入的 .ipynb 前注册 BufReadCmd。
    lazy = false,
    init = function()
      if vim.fn.has("win32") == 1 then
        -- Neovim 通过 UTF-8 管道发送代码，Python 桥接进程也必须按 UTF-8 解码。
        vim.env.PYTHONUTF8 = "1"
      end
    end,
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "neovim/nvim-lspconfig",
    },
    opts = {
      kernel = {
        -- 打开文件时不自动执行或启动内核，按 <leader>ji 手动启动。
        auto_connect = false,
        show_status = true,
        python_path = default_bridge_python(),
      },
      -- Neovide 不能使用插件的 Kitty 图片后端；保留单元格文本输出。
      images = { enabled = not vim.g.neovide },
      keymaps = {
        next_cell = "]j",
        prev_cell = "[j",
        kernel_start = "<leader>ji",
        menu_execute_cell = "<leader>jc",
        menu_execute_and_next = "<leader>jC",
        execute_cell = "<C-CR>",
        execute_and_next = "<S-CR>",
        execute_all_below = "<leader>jB",
        add_cell_above = "<leader>ja",
        add_cell_below = "<leader>jb",
        make_markdown = "<leader>jm",
        make_code = "<leader>jy",
        fold_toggle = "<leader>jf",
        open_output = "<leader>jo",
        clear_output = "<leader>jd",
        clear_all_outputs = "<leader>jD",
        kernel_interrupt = "<leader>jx",
        kernel_restart = "<leader>j0",
        kernel_shutdown = "<leader>jq",
        kernel_info = "<leader>jn",
        variable_inspect = "<leader>jh",
        cell_variables = "<leader>jl",
      },
    },
    config = function(_, opts)
      require("ipynb").setup(opts)
      vim.api.nvim_create_user_command("NotebookStartSelectedPython", start_selected_python, {
        desc = "使用 VenvSelect 选择的 Python 启动 Notebook 内核",
      })
      local function setup_environment_keys(buf)
        vim.keymap.set("n", "<leader>jv", "<cmd>VenvSelect<cr>", {
          buffer = buf,
          desc = "选择 Notebook Python 环境",
        })
        vim.keymap.set("n", "<leader>js", start_selected_python, {
          buffer = buf,
          desc = "使用选中的 Python 启动 Notebook 内核",
        })
      end
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "ipynb",
        group = vim.api.nvim_create_augroup("NotebookPython", { clear = true }),
        callback = function(event)
          setup_environment_keys(event.buf)
          -- 保留 ipynb 类型，单元格识别和 Markdown 注入依赖它。
          vim.bo[event.buf].textwidth = 0
        end,
      })
      -- 重新加载配置时，已经打开的 Notebook 也立即获得新快捷键。
      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.bo[buf].filetype == "ipynb" then
          setup_environment_keys(buf)
        end
      end
    end,
  },
}
