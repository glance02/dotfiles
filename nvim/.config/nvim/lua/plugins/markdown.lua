local markdownlint_config = vim.fn.stdpath("config") .. "/.markdownlint-cli2.yaml"

return {
  -- Markdown 警告检查
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters = {
        ["markdownlint-cli2"] = {
          prepend_args = {
            "--config",
            markdownlint_config,
          },
        },
      },
    },
  },

  -- Markdown 自动格式化也使用相同规则
  {
    "stevearc/conform.nvim",
    opts = {
      formatters = {
        ["markdownlint-cli2"] = {
          prepend_args = {
            "--config",
            markdownlint_config,
          },
        },
      },
    },
  },
}
