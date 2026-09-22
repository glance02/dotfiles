local mocha = require("colors.catppuccin_mocha")
local fonts = require("config.fonts")
local platform = require("utils.platform")()

return {
  term = "xterm-256color",
  animation_fps = 60,
  max_fps = 60,
  front_end = "OpenGL",
  -- The bundled WezTerm version can hit a Wayland buffer-scale protocol
  -- error on GNOME fractional scaling. XWayland is a reliable fallback.
  enable_wayland = not platform.is_linux,
  -- webgpu_power_preference = "HighPerformance",

  -- color scheme
  -- color_scheme = "Gruvbox dark, medium (base16)",
  color_scheme = "Catppuccin Mocha",

  -- background
  window_background_opacity = 1,
  win32_system_backdrop = "Disable",
  window_background_gradient = {
    colors = { mocha.crust, mocha.mantle, mocha.base },
    -- Specifices a Linear gradient starting in the top left corner.
    orientation = { Linear = { angle = -45.0 } },
  },

  -- scrollbar
  enable_scroll_bar = true,
  min_scroll_bar_height = "3cell",
  colors = {
    scrollbar_thumb = mocha.surface2,
  },

  -- tab bar
  enable_tab_bar = true,
  hide_tab_bar_if_only_one_tab = false,
  use_fancy_tab_bar = true,
  tab_max_width = 25,
  show_tab_index_in_tab_bar = true,
  switch_to_last_active_tab_when_closing_tab = true,

  -- cursor
  default_cursor_style = "BlinkingBlock",
  cursor_blink_ease_in = "Constant",
  cursor_blink_ease_out = "Constant",
  cursor_blink_rate = 700,

  -- window
  adjust_window_size_when_changing_font_size = false,
  -- Linux cannot embed native window controls in the tab bar in this
  -- WezTerm build; NONE keeps the desktop title bar out of the UI.
  window_decorations = "NONE",
  initial_cols = 120,
  initial_rows = 24,
  window_padding = {
    left = 5,
    right = 10,
    top = 12,
    bottom = 7,
  },
  window_close_confirmation = "NeverPrompt",
  window_frame = {
    active_titlebar_bg = mocha.mantle,
    inactive_titlebar_bg = mocha.crust,
    font = fonts.font,
    font_size = 11,
  },
  inactive_pane_hsb = { saturation = 1.0, brightness = 1.0 },
}
