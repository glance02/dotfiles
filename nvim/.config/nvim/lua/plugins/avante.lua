return {
  {
    "yetone/avante.nvim",

    dependencies = {
      {
        "ColinKennedy/mega.cmdparse",
        dependencies = {
          "ColinKennedy/mega.logging",
        },
      },
    },

    opts = {
      provider = "codex",

      acp_providers = {
        codex = {
          command = "codex-acp",
          args = {},
          env = {
            CODEX_PATH = vim.fn.exepath("codex"),
          },
        },
      },

      windows = {
        position = "right",
        width = 40,
      },
    },
  },
}
