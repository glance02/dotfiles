# yazi的快捷方式
function y {
	$tmp = (New-TemporaryFile).FullName
	yazi.exe $args --cwd-file="$tmp"
	$cwd = Get-Content -Path $tmp -Encoding UTF8
	if ($cwd -and $cwd -ne $PWD.Path -and (Test-Path -LiteralPath $cwd -PathType Container)) {
		Set-Location -LiteralPath (Resolve-Path -LiteralPath $cwd).Path
	}
	Remove-Item -Path $tmp
}

# 配置终端打开obsidian
$myVaults = @("note", "novel","2026年") 

Register-ArgumentCompleter -CommandName ob -ParameterName vault -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    
    $myVaults | Where-Object { $_ -like "$wordToComplete*" } | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}

function ob {
    param(
        [string]$vault = "note")
    
    $uri = "obsidian://open?vault=$vault"
    
    start $uri
}

# 配置PSReadLine
# 导入模块
Import-Module Catppuccin

# 选择一个风味（Latte / Frappe / Macchiato / Mocha）
$Flavor = $Catppuccin['Mocha']

# 配置 PSReadLine 语法高亮颜色
$Colors = @{
    # PowerShell 颜色
    ContinuationPrompt     = $Flavor.Teal.Foreground()
    Emphasis               = $Flavor.Red.Foreground()
    Selection              = $Flavor.Surface0.Background()

    # 自动补全预测颜色
    InlinePrediction       = $Flavor.Overlay0.Foreground()
    ListPrediction         = $Flavor.Mauve.Foreground()
    ListPredictionSelected = $Flavor.Surface0.Background()

    # 语法高亮
    Command   = $Flavor.Blue.Foreground()
    Comment   = $Flavor.Overlay0.Foreground()
    Default   = $Flavor.Text.Foreground()
    Error     = $Flavor.Red.Foreground()
    Keyword   = $Flavor.Mauve.Foreground()
    Member    = $Flavor.Rosewater.Foreground()
    Number    = $Flavor.Peach.Foreground()
    Operator  = $Flavor.Sky.Foreground()
    Parameter = $Flavor.Pink.Foreground()
    String    = $Flavor.Green.Foreground()
    Type      = $Flavor.Yellow.Foreground()
    Variable  = $Flavor.Lavender.Foreground()
}

Set-PSReadLineOption -Colors $Colors

# rclone同步
function sync {
    $localPath = (Get-Location).Path
    $folderName = Split-Path $localPath -Leaf
    $filterFile = "$HOME\.config\rclone\filter.txt"
    $remotePath = "mywebdav:obsidian/$folderName"
    
    Write-Host "双向同步 $localPath ↔ $remotePath"
    rclone bisync $localPath $remotePath --filter-from $filterFile -v @args
}

# bare仓库
function dgit { git --git-dir="$HOME\.dotfiles-git" --work-tree="$HOME" @args }
dgit config status.showUntrackedFiles no

# 使用starship
Invoke-Expression (&starship init powershell)

# 走clash流量
$env:HTTP_PROXY="http://127.0.0.1:7897"; $env:HTTPS_PROXY="http://127.0.0.1:7897"

# 初始化base环境
mamba activate base
cls


