return {
  {
    "catppuccin/nvim", -- 插件仓库地址：主题插件本体
    name = "catppuccin", -- 在 lazy.nvim 中注册的插件名，便于其他地方引用
    priority = 1000, -- 加载优先级；主题通常要尽早加载，避免被其他高亮覆盖
    config = function()
      require("catppuccin").setup({
        flavour = "mocha", -- 主题风格：latte / frappe / macchiato / mocha，这里是深色的 mocha
      })
      vim.cmd.colorscheme("catppuccin-nvim") -- 真正启用 catppuccin 颜色主题
    end,
  },
}
