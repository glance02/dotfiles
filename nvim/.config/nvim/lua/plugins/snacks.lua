return {
  {
    "folke/snacks.nvim",
    opts = {
      picker = {
        sources = {
          explorer = {
            actions = {
              recursive_toggle = function(picker, item)
                local Actions = require("snacks.explorer.actions")
                local Tree = require("snacks.explorer.tree")

                local function get_children(node)
                  local children = {}

                  for _, child in pairs(node.children) do
                    table.insert(children, child)
                  end

                  return children
                end

                local function refresh()
                  Actions.update(picker, { refresh = true })
                end

                local function toggle_recursive(node)
                  Tree:toggle(node.path)
                  refresh()

                  vim.schedule(function()
                    local children = get_children(node)

                    -- 如果不是“只有一个子项”，就停止递归
                    if #children ~= 1 then
                      return
                    end

                    local child = children[1]

                    -- 唯一的子项必须还是目录
                    if not child.dir then
                      return
                    end

                    -- 继续展开下一层
                    toggle_recursive(child)
                  end)
                end

                local node = Tree:node(item.file)

                if not node then
                  return
                end

                if node.dir then
                  toggle_recursive(node)
                else
                  -- 普通文件保持原来的打开行为
                  picker:action("confirm")
                end
              end,
            },

            win = {
              list = {
                keys = {
                  ["<CR>"] = "recursive_toggle",
                  ["l"] = "recursive_toggle",
                },
              },
            },

            layout = {
              layout = {
                width = 25,
              },
            },

            hidden = true,
          },
        },
      },

      terminal = {
        win = {
          position = "float",
          border = "rounded",
          width = 0.8,
          height = 0.8,
        },
      },
    },
  },
}
