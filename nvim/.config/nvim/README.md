# 💤 LazyVim

A starter template for [LazyVim](https://github.com/LazyVim/LazyVim).
Refer to the [documentation](https://lazyvim.github.io/installation) to get started.

## 写作模式

在普通模式或插入模式按 **F8** 切换写作模式，也可以使用 LazyVim 的
`<leader>uz`（默认依次按空格、u、z）。启动时不会自动进入。

- 正文居中，宽度为 88 个屏幕单元（约 44 个全角汉字），长段落按窗口折行。
- 隐藏行号、状态栏、标签栏、空白符标记和诊断提示，关闭语法范围淡化。
- 写作窗口关闭 Blink 自动补全、AI 补全候选及其签名提示，退出后恢复；不影响中文输入法候选。
- 仅在插入模式输入文字后调整视图，尽量保持当前行居中；不切换模式或移动插入光标，普通模式下正常浏览。
- Neovide 中保留现有字体名称，临时将字号设为 18 点、增加 4 像素行距并关闭光标粒子特效。
- 再次切换或关闭专注窗口后，恢复进入前的界面和 Neovide 设置。

纯文字可以直接使用 `.txt`，需要标题等标记时使用 `.md`。
写作模式复用已安装的 Snacks.nvim，无需额外安装插件。
排版参数在 `lua/plugins/writing.lua` 中调整。
文件顶部的 `font_size = 18` 是字体字号（点），例如可改为 `20`，不改变界面缩放倍率；
`extra_linespace = 4` 是额外增加的行距像素。修改后重启 Neovide 生效。
