return {
  {
    "rbong/vim-flog",
    cmd = { "Flog", "Flogsplit", "Floggit" },
    dependencies = {
      "tpope/vim-fugitive",
    },
    keys = {
      {
        "<leader>gv",
        "<cmd>Flog<cr>",
        desc = "Git Graph",
      },
    },
  },
}
