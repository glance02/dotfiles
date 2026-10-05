return {
  {
    "linux-cultist/venv-selector.nvim",

    opts = function(_, opts)
      opts.options = vim.tbl_deep_extend("force", opts.options or {}, {
        notify_user_on_venv_activation = true,
        search_timeout = 10,

        -- 开启日志，方便排查搜索命令
        log_level = "TRACE",

        -- 只显示环境名称，不显示重复的搜索来源列
        picker_columns = { "marker", "search_icon", "search_result" },

        -- 明确使用 PowerShell 7 执行搜索命令
        shell = {
          shell = "pwsh",
          shellcmdflag = "-NoLogo -NoProfile -Command",
        },
      })

      opts.search = opts.search or {}

      opts.search.mamba_envs = {
        -- venv-selector expands `$NAME` before invoking PowerShell. Use
        -- Get-Variable for the pipeline item so no PowerShell variables are
        -- altered during that expansion.
        -- Write paths with LF only; PowerShell's default CRLF would leave a
        -- carriage return in the selected path on Windows.
        command = [[mamba env list --json | ConvertFrom-Json | Select-Object -ExpandProperty envs | ForEach-Object { Join-Path (Get-Variable -Name _ -ValueOnly) "python.exe" } | Where-Object { Test-Path -LiteralPath (Get-Variable -Name _ -ValueOnly) } | ForEach-Object { [Console]::OpenStandardO2utput().Write([Text.Encoding]::UTF8.GetBytes([string](Get-Variable -Name _ -ValueOnly) + [char]10)) }]],

        -- 显示 mamba 环境名，而不是完整的 python.exe 路径
        on_telescope_result_callback = function(python_path)
          local environment_name = python_path:match("[\\/]([^\\/]+)[\\/]python%.exe$")
          if environment_name == "miniforge" then
            return "base"
          end
          return environment_name or python_path
        end,

        -- Mamba 和 Conda 的环境结构相同
        type = "anaconda",
      }
    end,
  },
}