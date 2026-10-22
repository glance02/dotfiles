-- 将解释器路径转换为简短名称；未识别的路径保留原样。
local function pretty_env_name(path, source)
  local normalized = path:gsub("\\", "/")

  return normalized:match("/envs/([^/]+)/python%.exe$")
    or normalized:match("/envs/([^/]+)/bin/python$")
    or (source and source:match("_base$") and "base")
    or path
end

local function miniforge_searches()
  local is_windows = vim.fn.has("win32") == 1
  local home = vim.fn.expand("~")
  local roots = {}
  local seen = {}

  -- 只保留存在的安装目录，并按规范化后的路径去重。
  local function add_root(path)
    if not path or path == "" then
      return
    end

    path = vim.fs.normalize(path)
    local key = path:gsub("\\", "/"):lower():gsub("/$", "")
    if vim.fn.isdirectory(path) == 1 and not seen[key] then
      seen[key] = true
      table.insert(roots, path)
    end
  end

  local function add_conda_prefix(path)
    if not path or path == "" then
      return
    end

    -- CONDA_PREFIX 可能指向某个环境；回退到其 envs 上级安装目录。
    local root = path:gsub("\\", "/"):match("^(.*)/envs/[^/]+$")
    add_root(root or path)
  end

  -- 优先使用当前环境提供的安装位置，避免依赖固定盘符或用户名。
  add_root(vim.env.MINIFORGE_HOME)
  add_root(vim.env.MAMBA_ROOT_PREFIX)
  add_conda_prefix(vim.env.CONDA_PREFIX)

  local conda_exe = vim.env.CONDA_EXE
  if not conda_exe or conda_exe == "" then
    conda_exe = vim.fn.exepath("conda")
  end
  if conda_exe and conda_exe ~= "" then
    -- Windows 的 conda 也可能在 Library/bin；向上查找实际安装根目录。
    local candidate = vim.fs.dirname(vim.fs.normalize(conda_exe))
    for _ = 1, 4 do
      if not candidate then
        break
      end
      if vim.fn.isdirectory(candidate .. "/conda-meta") == 1 then
        add_root(candidate)
        break
      end
      local parent = vim.fs.dirname(candidate)
      if parent == candidate then
        break
      end
      candidate = parent
    end
  end

  -- Conda 在本机登记的环境不依赖 PATH 或启动时是否已经激活环境。
  local registry = home .. "/.conda/environments.txt"
  if vim.fn.filereadable(registry) == 1 then
    for _, prefix in ipairs(vim.fn.readfile(registry)) do
      add_conda_prefix(prefix:gsub("\r$", ""))
    end
  end

  -- 补充常见默认目录，覆盖没有设置 Conda 环境变量的安装方式。
  for _, name in ipairs({ "miniforge3", "mambaforge", "miniconda3", "anaconda3" }) do
    add_root(home .. "/" .. name)
    add_root(home .. "/" .. name:gsub("3$", ""))
    if is_windows and vim.env.LOCALAPPDATA and vim.env.LOCALAPPDATA ~= "" then
      add_root(vim.env.LOCALAPPDATA .. "/" .. name)
    end
  end
  if not is_windows then
    add_root(home .. "/.local/share/mamba")
    add_root(home .. "/.conda")
    add_root("/opt/miniforge3")
    add_root("/opt/conda")
  end

  local env_dirs = {}
  local base_dirs = {}
  -- Windows 环境使用 python.exe；Unix 环境使用 bin/python。
  local env_pattern = is_windows and "python[.]exe$" or vim.fn.shellescape("bin/python$")
  local base_pattern = env_pattern
  local env_max_depth = is_windows and 2 or 3
  local base_max_depth = is_windows and 1 or 2
  local base_executable = is_windows and "/python.exe" or "/bin/python"

  for _, root in ipairs(roots) do
    local envs = root .. "/envs"
    if vim.fn.isdirectory(envs) == 1 then
      table.insert(env_dirs, vim.fn.shellescape(envs))
    end
    if vim.uv.fs_stat(root .. base_executable) then
      table.insert(base_dirs, vim.fn.shellescape(root))
    end
  end

  local searches = {}
  -- 只在对应目录存在时注册搜索，避免无效路径产生报错。
  if #env_dirs > 0 then
    searches.miniforge_envs = {
      command = "$FD "
        .. env_pattern
        .. " "
        .. table.concat(env_dirs, " ")
        .. " --max-depth "
        .. env_max_depth
        .. " --type f --full-path --absolute-path --color never",
      type = "anaconda",
    }
  end
  if #base_dirs > 0 then
    searches.miniforge_base = {
      command = "$FD "
        .. base_pattern
        .. " "
        .. table.concat(base_dirs, " ")
        .. " --max-depth "
        .. base_max_depth
        .. " --type f --full-path --absolute-path --color never",
      type = "anaconda",
    }
  end

  return searches
end

-- 切换环境和 LSP 重连后都同步，避免当前 buffer 继续使用旧解释器。
local function sync_python_lsp(bufnr)
  if not vim.api.nvim_buf_is_valid(bufnr) or vim.bo[bufnr].filetype ~= "python" then
    return 0
  end
  if vim.b[bufnr].venv_selector_disabled then
    return 0
  end

  local python = vim.b[bufnr].venv_selector_last_python
  if not python or python == "" then
    return 0
  end

  -- Conda on Windows: env/python.exe；普通 venv: env/Scripts/python.exe。
  local env_dir = vim.fs.dirname(python:gsub("\\", "/"))
  local executable_dir = vim.fs.basename(env_dir):lower()
  if executable_dir == "bin" or executable_dir == "scripts" then
    env_dir = vim.fs.dirname(env_dir)
  end

  local count = 0
  for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
    if client.name == "pyright" or client.name == "basedpyright" then
      local settings = vim.tbl_deep_extend("force", client.settings or {}, {
        python = {
          pythonPath = python,
          venvPath = vim.fs.dirname(env_dir),
          venv = vim.fs.basename(env_dir),
        },
      })
      client.settings = settings
      client.config.settings = settings
      client:notify("workspace/didChangeConfiguration", { settings = settings })
      count = count + 1
    end
  end
  return count
end

return {
  {
    "linux-cultist/venv-selector.nvim",
    ft = { "python", "ipynb" },
    keys = {
      { "<leader>cv", "<cmd>VenvSelect<cr>", desc = "选择 Python 环境", ft = { "python", "ipynb" } },
    },
    init = function()
      vim.api.nvim_create_autocmd({ "LspAttach", "BufEnter" }, {
        group = vim.api.nvim_create_augroup("PythonVenvLspSync", { clear = true }),
        callback = function(args)
          -- 等缓存环境恢复及 LSP 连接回调执行完，再读取 buffer 的最终环境。
          vim.schedule(function()
            sync_python_lsp(args.buf)
          end)
        end,
      })
    end,
    opts = {
      hooks = {
        function(python, env_type, bufnr)
          -- Pyright 支持动态更新配置，无需停止服务器和重新连接 buffer。
          if python and python ~= "" then
            return sync_python_lsp(bufnr or vim.api.nvim_get_current_buf())
          end
          return 0
        end,
      },
      options = {
        picker = "snacks",

        -- 隐藏搜索来源和长路径前的冗余列
        picker_columns = {
          "marker",
          "search_result",
        },

        -- 仅修改展示名称，不修改实际解释器路径
        on_telescope_result_callback = pretty_env_name,
      },

      search = miniforge_searches(),
    },
  },
}
