-- 将 Miniforge 路径转换为环境名称
local function pretty_env_name(path)
  local normalized = path:gsub("\\", "/")

  return normalized:match("/envs/([^/]+)/python%.exe$")
    or (normalized:match("/miniforge/python%.exe$") and "base")
    or path
end

return {
  {
    "linux-cultist/venv-selector.nvim",
    opts = {
      options = {
        picker = "snacks",

        -- 隐藏搜索来源和长路径前的冗余列
        picker_columns = {
          "marker",
          "search_result",
        },

        -- 仅修改展示名称，不修改实际解释器路径
        on_telescope_result_callback = pretty_env_name,
      },

      search = {
        miniforge_envs = {
          command = "$FD python[.]exe$ E:/Applications/miniforge/envs --max-depth 2 --type f --absolute-path --color never",
          type = "anaconda",
        },

        miniforge_base = {
          command = "$FD python[.]exe$ E:/Applications/miniforge --max-depth 1 --type f --absolute-path --color never",
          type = "anaconda",
        },
      },
    },
  },
}
