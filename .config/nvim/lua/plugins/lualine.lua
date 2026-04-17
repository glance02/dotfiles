return {
    "nvim-lualine/lualine.nvim", -- 底部状态栏插件
    dependencies = {
        "nvim-tree/nvim-web-devicons", -- 文件图标依赖，给状态栏中的文件类型等信息显示图标
    },
    event = "VeryLazy", -- 延迟加载，避免启动时优先初始化状态栏
    opts = {
        options = {
            theme = "auto", -- 状态栏主题；auto 会自动跟随当前 colorscheme
            component_separators = { left = "", right = "" }, -- 同一段内小组件之间的分隔符
            section_separators = { left = "", right = "" }, -- 大区块之间的分隔符
        },
        extensions = { "nvim-tree" }, -- 为 nvim-tree 侧边栏启用专门适配的状态栏布局
        sections = {
            lualine_b = { "branch", "diff" }, -- b 区显示当前 Git 分支和文件变更统计
            lualine_x = {
                "filesize", -- 当前文件大小
                "encoding", -- 文件编码，例如 utf-8
                "filetype", -- 当前缓冲区识别出的文件类型
            },
        },
    },
}

