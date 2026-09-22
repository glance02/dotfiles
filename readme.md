# Dotfiles

这个仓库使用 [GNU Stow](https://www.gnu.org/software/stow/) 管理配置文件。每个一级目录都是一个独立的 Stow package，目录中的路径从用户主目录开始映射。可以按工具单独安装、更新或移除。

## 目录结构

```text
nvim/
└── .config/nvim/                    -> ~/.config/nvim/

yazi/
└── .config/yazi/                    -> ~/.config/yazi/

wezterm/
└── .config/wezterm/                 -> ~/.config/wezterm/

glow/
└── .config/glow/                    -> ~/.config/glow/

rclone/
└── .config/rclone/                  -> ~/.config/rclone/

starship/
└── .config/starship.toml            -> ~/.config/starship.toml

crossnote/
└── .crossnote/                      -> ~/.crossnote/

powershell/
└── Documents/WindowsPowerShell/      -> ~/Documents/WindowsPowerShell/
    ├── Microsoft.PowerShell_profile.ps1
    └── Modules/Catppuccin/
```

`.crossnote` 是 VS Code Markdown Preview Enhanced (MPE) 的用户配置目录，包含自定义 CSS、主题、解析器和 Neovide 光标脚本。它需要直接位于用户主目录下，不能移动到 `~/.config`。

## 安装

在仓库根目录执行：

```shell
# 按需安装工具配置
stow --target="$HOME" nvim yazi wezterm glow rclone starship

# 安装 MPE 配置
stow --target="$HOME" crossnote
```

Windows 配置单独安装。建议在支持 GNU Stow 的环境（例如 MSYS2 或 WSL）中执行，并确认该环境中的 `$HOME` 指向 Windows 用户目录：

```shell
stow --target="$HOME" powershell
```

也可以一次安装多个 package：

```shell
stow --target="$HOME" nvim yazi wezterm glow rclone starship crossnote
```

移除链接时使用相同的 package 名称：

```shell
stow --target="$HOME" -D nvim yazi wezterm glow rclone starship crossnote
```

如果目标文件已经存在，先备份或移走它，再执行 `stow`。可以用 `stow -n -v` 预览操作而不真正创建链接。

## Windows 相关配置

`powershell` package 保留的是 Windows PowerShell 5.1 的路径：

```text
~/Documents/WindowsPowerShell/Microsoft.PowerShell_profile.ps1
~/Documents/WindowsPowerShell/Modules/Catppuccin/
```

PowerShell 7 通常使用 `~/Documents/PowerShell/`，如果以后迁移到 PowerShell 7，需要相应调整 package 内的目录名。

Catppuccin 模块由 profile 中的 `Import-Module Catppuccin` 加载。安装后重新打开 PowerShell，或手动执行：

```powershell
. $PROFILE
```

## 其他依赖

### 字体

使用 Maple Mono NF CN 字体。在 Scoop 中安装：

```powershell
scoop bucket add nerd-fonts
scoop install Maple-Mono-NF-CN
```

### yazi

yazi 配置位于 `~/.config/yazi/`。Windows PowerShell 中如需显式指定配置目录：

```powershell
[Environment]::SetEnvironmentVariable("YAZI_CONFIG_HOME", "$HOME\.config\yazi", "User")
```

yazi 的目录跳转功能依赖 `zoxide`，请先安装 `zoxide`。

### Neovim

Neovim 配置位于 `~/.config/nvim/`。Linux 上 Neovim 会直接读取这个路径；Windows 上如果使用 Neovim 默认的 `AppData/Local/nvim`，可以创建 Junction：

```powershell
New-Item -ItemType Junction -Path "$env:LOCALAPPDATA\nvim" -Target "$HOME\.config\nvim"
```
