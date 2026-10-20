# 💤 LazyVim

A starter template for [LazyVim](https://github.com/LazyVim/LazyVim).
Refer to the [documentation](https://lazyvim.github.io/installation) to get started.

## Jupyter Notebook（Neovide）

配置入口：`lua/plugins/notebook.lua`。使用 `ajbucci/ipynb.nvim` 直接读写 Notebook，旧的 Jupytext 转换已禁用。普通 `.py` 文件继续使用 Slime/IPython。

首次使用：

1. 在用于运行 Notebook 的 Python 环境执行 `python -m pip install jupyter_client ipykernel`。
2. 重启 Neovide，执行 `:Lazy install` 安装新插件。插件首次加载会编译 `ipynb` Tree-sitter 解析器，需要 C 编译器及 nvim-treesitter 要求的 tree-sitter CLI。
3. 执行 `:checkhealth ipynb`。若解析器尚未就绪，执行 `:TSInstall ipynb`，等待安装完成后重新打开 Notebook。
4. 运行 `neovide nvim/examples/notebook-demo.ipynb`。普通模式浏览单元格，按 `i` / 回车编辑当前格，按 Esc 返回 Notebook 视图。

打开文件不会自动启动内核。`<leader>ji` 默认使用 `~/miniforge3/envs/d2l` 的 Python 启动桥接进程；不存在该环境时优先查找 `python`，避免上游优先查找 `python3` 时误选 MSYS2。要使用其他环境，先按 `<leader>jv`（或 `<leader>cv`）打开环境选择器，再按 `<leader>js`；也可显式指定：`:NotebookKernelStart C:/path/to/env/python.exe`。选择 kernelspec 与选择桥接进程的 Python 是两件事，桥接环境中必须安装 `jupyter_client`。

Windows 下通过 `PYTHONUTF8=1` 让 Python 子进程使用 UTF-8，确保包含中文的代码通过桥接管道时不会被按本地编码误读。

切换环境时先 `<leader>jq` 关闭旧内核，再 `<leader>jv` 选择环境并 `<leader>js` 启动。Notebook 元数据中的 kernelspec 也会影响实际启动的内核；可通过 `:NotebookListKernels` 和 `:NotebookSetKernel` 检查与调整，在单元格运行 `import sys; print(sys.executable)` 核实执行环境。

| 快捷键 | 功能 |
| --- | --- |
| `<leader>jv` / `<leader>cv` | 打开 Python 环境选择器（支持 Notebook） |
| `<leader>ji` / `<leader>js` | 使用默认 d2l Python 启动 / 使用选中的 Python 启动 |
| `<leader>jc` / Ctrl+Enter | 执行当前单元格 |
| `<leader>jC` / Shift+Enter | 执行并跳到下一格 |
| `]j` / `[j` | 下一个 / 上一个单元格 |
| `<leader>ja` / `<leader>jb` | 在上方 / 下方插入单元格 |
| `<leader>jm` / `<leader>jy` | 转为 Markdown / 代码单元格 |
| `<leader>jo` | 浮窗查看并复制输出 |
| `<leader>jd` / `<leader>jD` | 清除当前格 / 全部输出 |
| `<leader>jB` | 执行当前及以下单元格 |
| `<leader>jx` / `<leader>j0` / `<leader>jq` | 中断 / 重启 / 关闭内核 |
| `<leader>jn` | 查看内核状态与环境 |
| `<leader>jh` / `<leader>jl` | 检查光标处变量 / 当前格变量 |

`:NotebookExecuteAll` 执行整个 Notebook。`:w` / `:NotebookSave` 保存代码及单元格输出。

Neovide 下已关闭 Kitty 图片后端，文本输出和 Markdown 渲染可用；图片和 HTML 交互输出不保证完整显示。插件目前处于 alpha 阶段。单元格的缓冲区快捷键与普通 Python 文件的 Slime 快捷键不同。

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
