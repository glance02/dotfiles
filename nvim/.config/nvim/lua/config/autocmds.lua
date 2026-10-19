-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- 去除对文本文件的拼写检查
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown", "text", "gitcommit", "plaintex", "typst" },
  callback = function()
    vim.opt_local.spell = false
  end,
})

-- 自动检查外部文件修改
vim.opt.autoread = true

vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter" }, {
  pattern = "*",
  command = "checktime",
})

-- 小狼毫的 vim_mode 只负责切回英文；由 Neovim 在进入插入模式时切回中文。
-- 直接切换 Rime 的中英文状态，无须切换 Windows 键盘布局或模拟 Shift。
if vim.fn.has("win32") == 1 then
  local weasel_server
  local warned = false

  -- 只影响当前 Neovim 会话；重新加载配置时保留开关状态。
  if vim.g.rime_auto_switch == nil then
    vim.g.rime_auto_switch = true
  end

  vim.api.nvim_create_user_command("Rime", function(opts)
    local action = opts.args
    if action == "enable" then
      vim.g.rime_auto_switch = true
    elseif action == "disable" then
      vim.g.rime_auto_switch = false
    elseif action == "toggle" then
      vim.g.rime_auto_switch = not vim.g.rime_auto_switch
    elseif action ~= "status" then
      vim.notify("用法：:Rime enable|disable|toggle|status", vim.log.levels.ERROR)
      return
    end
    vim.notify("Rime 自动切换：" .. (vim.g.rime_auto_switch and "已启用" or "已禁用"))
  end, {
    nargs = 1,
    desc = "Control automatic Rime input mode switching",
    complete = function(arg_lead)
      return vim.tbl_filter(function(action)
        return action:sub(1, #arg_lead) == arg_lead
      end, { "enable", "disable", "toggle", "status" })
    end,
  })

  local function find_weasel_server()
    local executable = vim.fn.exepath("WeaselServer.exe")
    if executable ~= "" then
      return executable
    end

    -- 从安装信息读取路径，兼容不同的小狼毫版本和安装目录。
    for _, registry in ipairs({
      { "HKCU\\Software\\Rime\\Weasel" },
      { "HKLM\\Software\\Rime\\Weasel", "/reg:32" },
      { "HKLM\\Software\\Rime\\Weasel", "/reg:64" },
    }) do
      local command = { "reg.exe", "query", registry[1], "/v", "WeaselRoot" }
      if registry[2] then
        table.insert(command, registry[2])
      end
      local result = vim.system(command, { text = true }):wait(1000)
      local root = result.code == 0 and result.stdout:match("WeaselRoot%s+REG_SZ%s+([^\r\n]+)")
      if root then
        executable = vim.trim(root) .. "/WeaselServer.exe"
        if vim.fn.filereadable(executable) == 1 then
          return executable
        end
      end
    end
  end

  vim.api.nvim_create_autocmd({ "InsertEnter", "InsertLeave" }, {
    group = vim.api.nvim_create_augroup("rime_input_mode", { clear = true }),
    desc = "Use Chinese in Insert mode and English in Normal mode",
    callback = function(event)
      -- 无界面运行（例如脚本或检查配置）时，不修改桌面输入法状态。
      if not vim.g.rime_auto_switch or #vim.api.nvim_list_uis() == 0 then
        return
      end
      if weasel_server == nil then
        weasel_server = find_weasel_server() or false
      end

      local message
      if weasel_server then
        -- 等待命令结束，避免快速切换模式时，中英文切换命令乱序完成。
        local option = event.event == "InsertEnter" and "/nascii" or "/ascii"
        local result = vim.system({ weasel_server, option }):wait(1000)
        if result.code ~= 0 then
          message = "小狼毫中英文切换失败，请检查 WeaselServer 是否正在运行。"
        end
      else
        message = "未找到 WeaselServer.exe，无法自动切换小狼毫中英文模式。"
      end
      if message and not warned then
        warned = true
        vim.schedule(function()
          vim.notify(message, vim.log.levels.WARN)
        end)
      end
    end,
  })
end
