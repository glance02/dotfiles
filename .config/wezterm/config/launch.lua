local platform = require("utils.platform")()
local dotfiles = require("utils.dotfiles")

local home = os.getenv("USERPROFILE") or os.getenv("HOME")
local pwsh = home .. "\\scoop\\shims\\pwsh.exe"

local options = {
  default_prog = {},
  launch_menu = {},
}

if platform.is_win then
  options.default_prog = { pwsh }
  options.launch_menu = {
    { label = " PowerShell v1", args = { "powershell" } },
    { label = " PowerShell v7", args = { pwsh } },
    { label = " Cmd", args = { "cmd" } },
    { label = " Nushell", args = { "nu" } },
    { label = " Dotfiles LazyGit", args = dotfiles.args() },
    {
      label = " GitBash",
      args = { "C:\\soft\\Git\\bin\\bash.exe" },
    },
  }
elseif platform.is_mac then
  options.default_prog = { "/opt/homebrew/bin/fish", "--login" }
  options.launch_menu = {
    { label = " Bash", args = { "bash", "--login" } },
    { label = " Fish", args = { "/opt/homebrew/bin/fish", "--login" } },
    { label = " Nushell", args = { "/opt/homebrew/bin/nu", "--login" } },
    { label = " Zsh", args = { "zsh", "--login" } },
  }
elseif platform.is_linux then
  options.default_prog = { "bash", "--login" }
  options.launch_menu = {
    { label = " Bash", args = { "bash", "--login" } },
    { label = " Fish", args = { "/opt/homebrew/bin/fish", "--login" } },
    { label = " Nushell", args = { "/opt/homebrew/bin/nu", "--login" } },
    { label = " Zsh", args = { "zsh", "--login" } },
  }
end

return options
