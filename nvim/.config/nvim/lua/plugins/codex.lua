return {
  {
    "ishiooon/codex.nvim",
    dependencies = {
      "folke/snacks.nvim",
    },
    config = true,
    keys = {
      {
        "<leader>cc",
        "<cmd>Codex<cr>",
        desc = "Codex: Toggle",
      },
      {
        "<leader>ci",
        "<cmd>CodexFocus<cr>",
        desc = "Codex: Focus",
      },
      {
        "<leader>cx",
        "<cmd>CodexMaximizeToggle<cr>",
        desc = "Codex: Maximize",
      },
    },
  },
}
