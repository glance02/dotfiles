return {
  {
    "olimorris/codecompanion.nvim",

    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },

    opts = {
      adapters = {
        acp = {
          codex = function()
            return require("codecompanion.adapters").extend("codex", {
              env = {
                -- 本机的 codex-acp 需要显式指定已安装的 Codex。
                -- Windows 下使用 npm 的 .cmd 入口。
                CODEX_PATH = vim.fn.exepath(vim.fn.has("win32") == 1 and "codex.cmd" or "codex"),
              },
              handlers = {
                -- 沿用 Codex 已有的配置和认证，由 ACP 服务端检查。
                -- 避免插件默认发起 API Key 登录，覆盖已有的登录方式。
                auth = function()
                  return true
                end,
              },
            })
          end,
        },
      },

      -- 通过 ACP 在 CodeCompanion 原生聊天缓冲区中使用 Codex。
      interactions = {
        chat = {
          adapter = "codex",
        },
      },

      display = {
        chat = {
          window = {
            layout = "vertical",
            position = "right",
            width = 0.4,
          },
          start_in_insert_mode = true,
        },
      },
    },

    -- ============================================================
    -- 快捷键
    -- ============================================================
    keys = {
      -- ------------------------------------------------------------
      -- Space a a
      --
      -- 打开 / 隐藏 CodeCompanion 聊天
      -- ------------------------------------------------------------
      {
        "<leader>aa",
        "<cmd>CodeCompanionChat Toggle<cr>",
        mode = { "n", "v" },
        desc = "Toggle Codex Chat",
      },

      -- Space a p：打开操作面板，可在普通 / 可视模式中使用。
      {
        "<leader>ap",
        "<cmd>CodeCompanionActions<cr>",
        mode = { "n", "v" },
        desc = "CodeCompanion Actions",
      },

      -- ------------------------------------------------------------
      -- Space a c
      --
      -- 创建一个新的 CodeCompanion 聊天会话
      -- ------------------------------------------------------------
      {
        "<leader>ac",
        function()
          require("codecompanion").chat()
        end,
        desc = "New Codex Chat",
      },

      -- ------------------------------------------------------------
      -- Visual 模式：Space a s
      --
      -- 将选区添加到聊天，补充问题后再发送
      -- ------------------------------------------------------------
      {
        "<leader>as",
        "<cmd>CodeCompanionChat Add<cr>",
        mode = "v",
        desc = "Add Selection to Codex Chat",
      },
    },

    -- 聊天窗口沿用内置快捷键，无须重复设置：
    -- Ctrl+s 发送；Ctrl+c 关闭（普通 / 插入模式）。
    -- 普通模式：? 操作列表，q 停止，gr 重新生成，gy 复制代码。
    -- 普通模式：{ / } 切换聊天，[[ / ]] 跳转消息，ga 切换模型。
  },
}
