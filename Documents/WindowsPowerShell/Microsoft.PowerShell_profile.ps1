function y {
	$tmp = (New-TemporaryFile).FullName
	yazi.exe $args --cwd-file="$tmp"
	$cwd = Get-Content -Path $tmp -Encoding UTF8
	if ($cwd -and $cwd -ne $PWD.Path -and (Test-Path -LiteralPath $cwd -PathType Container)) {
		Set-Location -LiteralPath (Resolve-Path -LiteralPath $cwd).Path
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

function dgit { git --git-dir="$HOME\.dotfiles-git" --work-tree="$HOME" @args }
dgit config status.showUntrackedFiles no

Invoke-Expression (&starship init powershell)

$env:HTTP_PROXY="http://127.0.0.1:7897"; $env:HTTPS_PROXY="http://127.0.0.1:7897"

mamba activate base
cls


