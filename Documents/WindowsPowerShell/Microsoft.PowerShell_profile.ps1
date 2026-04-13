function ya {
    $tmp = [System.IO.Path]::GetTempFileName()
    yazi $args --cwd-file="$tmp"
    $cwd = Get-Content -Path $tmp -First 1   
    if ($cwd -and $cwd -ne $PWD.Path -and (Test-Path $cwd)) {
        Set-Location -LiteralPath $cwd
    }
    Remove-Item -Path $tmp
}

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

function dotfiles { git --git-dir="$HOME\.dotfiles-git" --work-tree="$HOME" @args }
dotfiles config status.showUntrackedFiles no

Invoke-Expression (&starship init powershell)

mamba activate base
cls