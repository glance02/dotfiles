## Windows 上的完整方案

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
dgit status # 查看当前状态，看看有哪些文件被修改了但还没有提交
dgit add <file> # 把修改了的文件加入暂存区
dgit add -u # 把所有修改了的文件加入暂存区
dgit commit -m "update dotfiles" # 提交修改
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
