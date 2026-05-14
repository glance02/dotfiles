return {
  -- ref: https://wezfurlong.org/wezterm/config/lua/SshDomain.html
  ssh_domains = {
    {
      multiplexing = "None",
      name = "seborid",
      remote_address = "frp-way.com:36980",
      username = "seborid",
    },
    {
      multiplexing = "None",
      name = "myserver",
      remote_address = "glacne02.xyz:6419",
      username = "root",
      ssh_option = {
        identityfile = "C:\\Users\\86199\\.ssh\\id_ed25519.pub",
      },
    },
  },

  -- ref: https://wezfurlong.org/wezterm/multiplexing.html#unix-domains
  unix_domains = {},

  -- ref: https://wezfurlong.org/wezterm/config/lua/WslDomain.html
  wsl_domains = {
    {
      name = "WSL:Ubuntu-24.04",
      distribution = "Ubuntu-24.04",
      username = "glance",
      default_cwd = "/home/glance",
      default_prog = { "bash", "--login" },
    },
  },
}
