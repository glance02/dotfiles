return {
  {
    "nvim-tree/nvim-tree.lua", -- 文件树侧边栏插件
    dependencies = {
      "nvim-tree/nvim-web-devicons", -- 给文件和目录显示图标
    },

    init = function()
      vim.g.loaded_netrw = 1 -- 禁用内置 netrw，避免和 nvim-tree 功能冲突
      vim.g.loaded_netrwPlugin = 1 -- 禁用 netrw 插件部分，确保由 nvim-tree 接管目录浏览
    end,

    keys = {
      { "<leader>e", "<cmd>NvimTreeToggle<CR>", desc = "Toggle nvim-tree" }, -- <leader>e 用来打开/关闭文件树
    },

    opts = {
      sort = {
        sorter = "case_sensitive", -- 排序方式：区分大小写来排序文件名
      },
      view = {
        width = 30, -- 文件树窗口宽度，单位通常是字符列
      },
      renderer = {
        group_empty = true, -- 将连续的空目录合并显示，减少层级占用
      },
      filters = {
        dotfiles = false, -- 是否隐藏点文件；false 表示显示 .gitignore 这类文件
      },
    },
  },
}
