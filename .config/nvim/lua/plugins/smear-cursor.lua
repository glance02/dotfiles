return {
  {
    "sphamba/smear-cursor.nvim",
    event = "VeryLazy",
    opts = {
      cursor_color = "#FFC0CB", -- 拖影的主颜色
      stiffness = 0.5, -- 主光标追赶目标位置的“弹性强度”；越大越快收敛
      trailing_stiffness = 0.1, -- 尾迹部分的弹性强度；越小拖尾越柔和
      trailing_exponent = 5, -- 尾迹衰减曲线；越大表示尾巴越短、末端衰减越明显
      gamma = 1, -- 颜色/亮度曲线修正；1 表示基本保持原始强度
    },
  },
}
