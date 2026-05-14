## 个人配置文件管理

### yazi 配置

加了Catppuccin 主题，然后把配置文件放在了`~/.config/yazi/`里，使用 Git 管理。需要在环境变量中加入一个变量才能从该处访问配置文件。在Powershell中执行：

```powershell
[Environment]::SetEnvironmentVariable("YAZI_CONFIG_HOME", "$HOME\.config\yazi", "User")
```
### nvim配置

我把nvim的配置放在了`$HOME\.config\nvim\`里，使用 Git 管理。但是nvim的默认配置文件放在`$HOME\AppData\Local\nvim\`里，所以需要在这两个文件夹中加一个软链接。如果没有对应配置文件的话就自己在对应位置创建一个。

使用如下powershell命令：

```powershell
New-Item -ItemType Junction -Path "$env:LOCALAPPDATA\nvim" -Target "$HOME\.config\nvim"
```

或者使用cmd命令：

```cmd
mklink /j "%LOCALAPPDATA%\nvim" "%USERPROFILE%\.config\nvim"
```

## Windows 上的bare方案

### 初始操作

**第一步：在 PowerShell 里初始化**

```powershell
git init --bare $HOME\.dotfiles-git

# 设置 Function（PowerShell 里没有 alias 传参，用 Function）
function dgit { git --git-dir="$HOME\.dotfiles-git" --work-tree="$HOME" @args }
```

**第二步：把这个 Function 加到 PowerShell 配置文件里，让它每次自动加载**

```powershell
# 查看配置文件路径
echo $PROFILE

# 用记事本打开（没有就会新建）
notepad $PROFILE
```

在打开的文件里加入：

```powershell
function dgit { git --git-dir="$HOME\.dotfiles-git" --work-tree="$HOME" @args }
dgit config status.showUntrackedFiles no
```

**第三步：开始追踪配置文件**

```powershell
dgit add $HOME\AppData\Local\nvim\init.lua
dgit add $PROFILE   # PowerShell 配置文件本身也可以加进去！
dgit commit -m "initial dotfiles"
```

**第四步：推到 GitHub**

```powershell
dgit remote add origin git@github.com:glance02/dotfiles.git
dgit push -u origin main
```
### 后续更新操作

似乎是不能在vscode中可视化操作，所以需要用到一些`git`的命令行操作

```powershell
dgit ls-files # 列出所有被追踪的文件
dgit rm --cached <file> # 将文件从git追踪中移除，但不删除文件本身
dgit status # 查看当前状态，看看有哪些文件被修改了但还没有提交
dgit add <file> # 把修改了的文件加入暂存区
dgit add -u # 把所有修改了的文件加入暂存区
dgit commit -m "update dotfiles" # 提交修改
```

针对添加配置文件夹的中的文件，可以使用$HOME来找到用户目录，在此以添加yazi配置文件的例子提一下：

```powershell
 dgit add $HOME/.config/yazi/  
```

尤其注意不要直接使用`dgit add .`，因为这样会把所有未被追踪的文件也加入暂存区。。

---

## 新电脑恢复时

```powershell
git clone --bare git@github.com:glance02/dotfiles.git $HOME\.dotfiles-git

function dgit { git --git-dir="$HOME\.dotfiles-git" --work-tree="$HOME" @args }

dgit checkout
dgit config status.showUntrackedFiles no
```

---

## Windows 常见配置文件位置参考

| 软件 | 配置文件路径 |
|------|------------|
| PowerShell | `$PROFILE`（通常在 `Documents\PowerShell\`） |
| Git | `~\.gitconfig` |
| Neovim | `~\AppData\Local\nvim\` |
| Windows Terminal | `~\AppData\Local\Packages\...\settings.json` |
| Scoop 本身 | 可以把 `scoop install` 列表写进一个脚本一起管理 |
