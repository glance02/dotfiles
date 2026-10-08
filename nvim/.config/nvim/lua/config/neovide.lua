if not vim.g.neovide then
  return
end

-- =========================================================
-- Font
-- =========================================================

-- Maple Mono NF CN:
--   - Maple Mono
--   - Nerd Font icons
--   - Chinese / Japanese glyphs
vim.o.guifont = "Maple Mono NF CN:h13"

-- =========================================================
-- Cursor animation
-- =========================================================

-- 光标从当前位置移动到目标位置所需时间
vim.g.neovide_cursor_animation_length = 0.10

-- 只移动 1~2 个字符时使用更短的动画
-- 打字时不会显得拖沓
vim.g.neovide_cursor_short_animation_length = 0.03

-- 拖尾程度，范围 0~1
-- 1 最大拖尾，数值越低越平滑、尾巴越短
vim.g.neovide_cursor_trail_size = 0.7

-- 插入模式也启用动画
vim.g.neovide_cursor_animate_in_insert_mode = true

-- 编辑区与命令行之间切换时启用动画
vim.g.neovide_cursor_animate_command_line = true

-- 光标抗锯齿
vim.g.neovide_cursor_antialiasing = true

-- =========================================================
-- Cursor VFX
-- =========================================================

-- 不开启粒子特效
-- 可选：
-- "railgun"
-- "torpedo"
-- "pixiedust"
-- "sonicboom"
vim.g.neovide_cursor_vfx_mode = "railgun"
vim.g.neovide_cursor_vfx_particle_lifetime = 0.35
vim.g.neovide_cursor_vfx_particle_density = 0.7
vim.g.neovide_cursor_vfx_particle_speed = 10.0

-- =========================================================
-- Scrolling
-- =========================================================

-- 滚动动画持续时间
vim.g.neovide_scroll_animation_length = 0.20

-- 远距离滚动超过一定行数时直接跳过去，
-- 避免动画拖太久
vim.g.neovide_scroll_animation_far_lines = 1

-- =========================================================
-- Refresh rate
-- =========================================================

-- 根据你的屏幕刷新率修改
vim.g.neovide_refresh_rate = 90

-- 窗口失去焦点后的刷新率
vim.g.neovide_refresh_rate_idle = 5

-- =========================================================
-- Window
-- =========================================================

-- 记住上一次 Neovide 窗口尺寸
vim.g.neovide_remember_window_size = true

-- 浮点窗口阴影
vim.g.neovide_floating_shadow = true

-- 窗口外观
-- 先设置一个深色兜底；主题加载后会在下面自动同步实际的 Normal 配色。
vim.g.neovide_background_color = "#1a1b26"
vim.g.neovide_title_background_color = "#1a1b26"
vim.g.neovide_title_text_color = "#a9b1d6"
vim.g.neovide_show_border = false

-- 标题栏只显示应用名称，不显示当前文件路径。
vim.opt.title = true
vim.opt.titlestring = "Neovide"

local function sync_neovide_colors()
  local normal = vim.api.nvim_get_hl(0, { name = "Normal", link = false })
  local background = normal.bg and string.format("#%06x", normal.bg) or "#1a1b26"
  local foreground = normal.fg and string.format("#%06x", normal.fg) or "#a9b1d6"

  vim.g.neovide_background_color = background
  vim.g.neovide_title_background_color = background
  vim.g.neovide_title_text_color = foreground
end

vim.api.nvim_create_autocmd("ColorScheme", {
  callback = sync_neovide_colors,
  desc = "Sync Neovide window colors with the active colorscheme",
})
vim.schedule(sync_neovide_colors)

-- =========================================================
-- Input
-- =========================================================

-- Ctrl + Shift + V 粘贴
vim.keymap.set("n", "<C-S-v>", '"+p', { silent = true })
vim.keymap.set("v", "<C-S-v>", '"+p', { silent = true })
vim.keymap.set("i", "<C-S-v>", "<C-r>+", { silent = true })
vim.keymap.set("c", "<C-S-v>", "<C-r>+", { silent = true })

-- 配置F11快捷键
if vim.g.neovide then
  vim.keymap.set("n", "<F11>", function()
    vim.g.neovide_fullscreen = not vim.g.neovide_fullscreen
  end, { desc = "Toggle Neovide Fullscreen" })
end
