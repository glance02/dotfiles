local markdownlint_config = vim.fn.stdpath("config") .. "/.markdownlint-cli2.yaml"

return {
  -- 为 Markdown 文档和 CodeCompanion 聊天启用渲染。
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown", "codecompanion" },
    opts = function(_, opts)
      opts.file_types = opts.file_types or { "markdown" }
      if not vim.tbl_contains(opts.file_types, "codecompanion") then
        table.insert(opts.file_types, "codecompanion")
      end

      opts.overrides = opts.overrides or {}
      opts.overrides.filetype = opts.overrides.filetype or {}
      opts.overrides.filetype.codecompanion =
        vim.tbl_deep_extend("force", opts.overrides.filetype.codecompanion or {}, {
          -- 输入问题时继续渲染回答；光标经过表格时也保留排版。
          render_modes = true,
          anti_conceal = { enabled = false },
        })
    end,
  },

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
