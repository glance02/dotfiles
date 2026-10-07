return {
  {
    "ishiooon/codex.nvim",
    dependencies = {
      "folke/snacks.nvim",
    },
    config = true,

    keys = {
      {
        "<leader>ac",
        "<cmd>Codex<cr>",
        desc = "Codex: Toggle",
      },
      {
        "<leader>af",
        "<cmd>CodexFocus<cr>",
        desc = "Codex: Focus",
      },
      {
        "<leader>am",
        "<cmd>CodexMaximizeToggle<cr>",
        desc = "Codex: Maximize",
      },
      {
        "<leader>as",
        "<cmd>CodexSend<cr>",
        mode = "v",
        desc = "Codex: Send selection",
      },
    },
  },
}
