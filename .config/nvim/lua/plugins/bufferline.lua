return {
  "akinsho/bufferline.nvim",
  dependencies = "nvim-tree/nvim-web-devicons",
  event = "VeryLazy",
  keys = {
    { "<Tab>",      "<cmd>BufferLineCycleNext<cr>", desc = "下一个 Buffer" },
    { "<S-Tab>",    "<cmd>BufferLineCyclePrev<cr>", desc = "上一个 Buffer" },
    { "<leader>bd", "<cmd>bdelete<cr>",             desc = "关闭当前 Buffer" },
    { "<leader>bD", "<cmd>BufferLineCloseOthers<cr>", desc = "关闭其他 Buffer" },
    { "<leader>bf", "<cmd>BufferLinePick<cr>",      desc = "快速跳转 Buffer" },
  },
  opts = {
    options = {
      separator_style = "slope",
      always_show_bufferline = true,
    },
  },
}
