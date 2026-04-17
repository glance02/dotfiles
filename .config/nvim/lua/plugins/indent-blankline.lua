return {
    "lukas-reineke/indent-blankline.nvim", -- 缩进辅助线插件
    event = "VeryLazy", -- 延迟到空闲阶段再加载，减少启动时阻塞
    main = "ibl", -- 指定插件的主模块名；新版 indent-blankline 通过 ibl 模块暴露配置
    opts = {}, -- 传给 require("ibl").setup() 的参数；空表表示使用插件默认配置
}

