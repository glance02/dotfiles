# Dotfiles

这个仓库使用 [Dotbot](https://github.com/anishathalye/dotbot) 管理配置文件。`install.conf.yaml` 负责把仓库中的配置链接到用户目录。

## 目录结构

```text
nvim/
└── .config/nvim/                    -> ~/.config/nvim/

yazi/
└── .config/yazi/                    -> ~/.config/yazi/
    ├── init.lua, keymap.toml, ...   # 个人配置
    └── package.toml                  # ya 插件清单

wezterm/
└── .config/wezterm/                 -> ~/.config/wezterm/

glow/
└── .config/glow/                    -> ~/.config/glow/

rclone/
└── .config/rclone/                  -> ~/.config/rclone/

starship/
└── .config/starship.toml            -> ~/.config/starship.toml

crossnote/
└── .config/.crossnote/              -> ~/.config/.crossnote/

powershell/
└── Documents/WindowsPowerShell/      -> ~/Documents/WindowsPowerShell/
    ├── Microsoft.PowerShell_profile.ps1
    └── Modules/Catppuccin/
```

`.crossnote` 是 VS Code Markdown Preview Enhanced (MPE) 的用户配置目录，包含自定义 CSS、主题、解析器和 Neovide 光标脚本。当前配置将它安装到 `~/.config/.crossnote`。

## 安装

在仓库根目录执行：

```powershell
.\install.ps1
```

安装前可以先预览变更：

```powershell
.\install.ps1 -n
```

当前 YAML 不包含 `powershell` 配置包；如需安装它，需要另行加入链接规则。

## Linux 使用说明

Linux 直接使用 `$HOME/.config` 下的配置路径。克隆仓库后，在仓库根目录执行：

```bash
./install
```

安装前可以预览变化：

```bash
./install -n
```

Dotbot 会根据 `install.conf.yaml` 创建或更新配置链接。Neovim、Yazi、WezTerm、Glow、Rclone、Starship 和 Crossnote 的配置都会按目录结构链接到 `$HOME`。

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

插件由 `package.toml` 管理，不把插件源码提交到此仓库。完成 Dotbot 链接后，在 Yazi 配置目录执行：

```powershell
ya pkg install
```

### Neovim

Neovim 配置位于 `~/.config/nvim/`。Linux 上 Neovim 会直接读取这个路径；Windows 上如果使用 Neovim 默认的 `AppData/Local/nvim`，可以创建 Junction：

```powershell
New-Item -ItemType Junction -Path "$env:LOCALAPPDATA\nvim" -Target "$HOME\.config\nvim"
```

Linux 上 Neovim 默认读取 `~/.config/nvim`，无需额外创建 Junction。Yazi 默认读取 `~/.config/yazi`；如果环境没有自动识别该路径，可以设置：

```bash
export YAZI_CONFIG_HOME="$HOME/.config/yazi"
```

如需永久生效，将这行加入使用中的 shell 配置文件，例如 `~/.bashrc` 或 `~/.zshrc`。
