local opt = vim.opt

opt.number = true
opt.relativenumber = true

opt.cursorline = true

-- 缩进
opt.tabstop = 4
opt.shiftwidth = 4
opt.softtabstop = 4
opt.expandtab = true
opt.autoindent = true
opt.smartindent = true

-- 系统剪贴板
opt.clipboard:append("unnamedplus")

opt.showmode = false
opt.shell = "powershell"

opt.splitbelow = true
opt.splitright = true
