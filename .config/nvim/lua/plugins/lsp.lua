return {
  -- 包管理器
  {
    "williamboman/mason.nvim",
    config = true,
  },

  -- 桥接层
  {
    "williamboman/mason-lspconfig.nvim",
    opts = {
      -- 想自动安装的 LSP，填在这里
      ensure_installed = {"pyright" },
      automatic_installation = true,
    },
  },

  -- LSP 配置
  {
    "neovim/nvim-lspconfig",
    config = function()
       local capabilities = require("cmp_nvim_lsp").default_capabilities()

      -- 每个 LSP 单独配置
      vim.lsp.config("pyright",{
        capabilities = capabilities,
      })

      vim.lsp.enable({"pyright"})

      -- 通用快捷键，只在有 LSP 的 buffer 生效
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(event)
          local map = function(key, cmd, desc)
            vim.keymap.set("n", key, cmd, { buffer = event.buf, desc = desc })
          end

          map("gd", vim.lsp.buf.definition,      "跳转到定义")
          map("gr", vim.lsp.buf.references,      "查看引用")
          map("K",  vim.lsp.buf.hover,           "查看文档")
          map("<leader>rn", vim.lsp.buf.rename,  "重命名")
          map("<leader>ca", vim.lsp.buf.code_action, "Code Action")
        end,
      })
    end,
  },
}
