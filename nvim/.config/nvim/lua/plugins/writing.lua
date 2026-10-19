-- 按 F8 进入/退出写作模式；启动时保持原来的编辑环境。
-- 写作模式的字体字号（点），直接修改 guifont 的 :h，不缩放界面。
local font_size = 16
local extra_linespace = 4

local neovide_state
local writing_win

local function center_input(win)
  local view = vim.fn.winsaveview()
  local row = view.lnum - 1
  local above = math.floor(vim.api.nvim_win_get_height(win.win) / 2)
  local top = math.max(0, row - above)
  local height = vim.api.nvim_win_text_height(win.win, {
    start_row = top,
    end_row = row,
    end_vcol = vim.fn.virtcol("."),
  }).all
  local skip = math.max(0, height - above - 1)

  -- 按屏幕行计算滚动位置，兼容中文长段落的折行。
  while top < row do
    local line_height = vim.api.nvim_win_text_height(win.win, { start_row = top, end_row = top }).all
    if skip < line_height then
      break
    end
    skip = skip - line_height
    top = top + 1
  end

  local skipcol = 0
  if skip > 0 then
    local line = vim.api.nvim_win_text_height(win.win, { start_row = top, end_row = top })
    local low, high = 1, line.end_vcol
    while low < high do
      local mid = math.floor((low + high) / 2)
      local prefix = vim.api.nvim_win_text_height(win.win, {
        start_row = top,
        end_row = top,
        end_vcol = mid,
      }).all
      if prefix > skip then
        high = mid
      else
        low = mid + 1
      end
    end
    skipcol = low - 1
  end

  -- 只改变视图，不切换编辑模式或移动插入光标。
  view.topline = top + 1
  view.topfill = 0
  view.skipcol = skipcol
  vim.fn.winrestview(view)
end

return {
  {
    "folke/snacks.nvim",
    keys = {
      {
        "<F8>",
        function()
          Snacks.zen()
        end,
        mode = { "n", "i" },
        desc = "切换写作模式",
      },
    },
    opts = {
      zen = {
        -- 小说不需要按代码语法淡化正文。
        toggles = {
          dim = false,
          git_signs = false,
          mini_diff_signs = false,
          diagnostics = false,
          inlay_hints = false,
        },
        show = { statusline = false, tabline = false },
        win = {
          -- 88 个屏幕单元约为 44 个全角汉字，小窗口会自动缩窄。
          width = 88,
          -- blend=100 会跳过遮罩；使用不透明背景完全盖住原窗口。
          backdrop = {
            transparent = false,
            blend = 0,
            win = {
              wo = { winhighlight = "Normal:Normal", winblend = 0 },
            },
          },
          wo = {
            number = false,
            relativenumber = false,
            signcolumn = "no",
            foldcolumn = "0",
            foldenable = false,
            colorcolumn = "",
            cursorline = false,
            cursorcolumn = false,
            list = false,
            spell = false,
            wrap = true,
            linebreak = true,
            breakindent = false,
            showbreak = "",
            scrolloff = 8,
            smoothscroll = true,
          },
        },
        on_open = function(win)
          writing_win = win
          -- 已经弹出的候选框也立即收起；不为此主动加载补全插件。
          local cmp = package.loaded["blink.cmp"]
          if cmp then
            cmp.hide()
            cmp.hide_signature()
          end

          -- 仅在输入文字后居中，避免光标移动事件反复触发居中。
          -- 窗口关闭时自动清理这些事件。
          win:on("TextChangedI", function()
            if win:valid() and vim.api.nvim_get_current_win() == win.win and vim.fn.mode():sub(1, 1) == "i" then
              center_input(win)
            end
          end)

          if not vim.g.neovide then
            return
          end

          -- 保存实际值，包括未设置的变量，退出时原样恢复。
          neovide_state = {
            font = vim.o.guifont,
            linespace = vim.o.linespace,
            vfx = vim.g.neovide_cursor_vfx_mode,
          }
          local font, replaced = neovide_state.font:gsub(":h[%d.]+", ":h" .. font_size)
          vim.o.guifont = replaced > 0 and font or (font .. ":h" .. font_size)
          vim.o.linespace = neovide_state.linespace + extra_linespace
          vim.g.neovide_cursor_vfx_mode = ""
        end,
        on_close = function()
          writing_win = nil
          if not neovide_state then
            return
          end

          vim.o.guifont = neovide_state.font
          vim.o.linespace = neovide_state.linespace
          vim.g.neovide_cursor_vfx_mode = neovide_state.vfx
          neovide_state = nil
        end,
      },
    },
  },
  {
    "saghen/blink.cmp",
    opts = function(_, opts)
      local enabled = opts.enabled
      opts.enabled = function()
        -- 只关闭写作窗口的补全，退出后继续使用原来的启用规则。
        if writing_win and writing_win:valid() and vim.api.nvim_get_current_win() == writing_win.win then
          return false
        end
        if type(enabled) == "function" then
          return enabled()
        end
        return enabled ~= false
      end
    end,
  },
}
