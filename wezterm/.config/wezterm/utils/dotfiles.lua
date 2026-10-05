local home = os.getenv("USERPROFILE") or os.getenv("HOME")
local pwsh = home .. "\\scoop\\shims\\pwsh.exe"

local command = [=[
$env:GIT_DIR = Join-Path $env:USERPROFILE ".dotfiles-git"
$env:GIT_WORK_TREE = $env:USERPROFILE

if (-not (Get-Command lazygit -ErrorAction SilentlyContinue)) {
  Write-Host ""
  Write-Host "lazygit is not installed." -ForegroundColor Yellow
  Write-Host "Install with: scoop install lazygit" -ForegroundColor Cyan
  Write-Host ""
  git --git-dir=$env:GIT_DIR --work-tree=$env:GIT_WORK_TREE status --short
  return
}

Set-Location $env:GIT_WORK_TREE
lazygit
]=]

return {
  args = function()
    return { pwsh, "-NoExit", "-Command", command }
  end,
}
