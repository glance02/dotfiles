-- 设置空格为 Leader
vim.g.mapleader = " "

-- 开启 Which-key 提示
vim.opt.whichkey = "all"

-- Space + e 打开 Oil
vim.keymap.set("n", "<leader>e", ":Oil .<CR>", {
	desc = "Open Oil at vault root",
})

-- 仅在 Oil 文件管理器中生效
vim.api.nvim_create_autocmd("OilEnter", {
	callback = function()
		-- h：返回上一级目录
		vim.keymap.set("n", "h", function()
			vim.obsidian.oil.parent()
		end, {
			buffer = 0,
			desc = "Parent directory",
		})

		-- l：打开文件或进入目录
		vim.keymap.set("n", "l", function()
			vim.obsidian.oil.open_entry()
		end, {
			buffer = 0,
			desc = "Open entry",
		})
	end,
})
