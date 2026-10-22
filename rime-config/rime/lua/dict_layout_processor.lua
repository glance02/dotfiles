-- Ctrl+Shift+E：在「释义竖排 5 候选」和「普通横排 7 候选」之间切换。
-- 两个方案共用词库；切换时恢复输入编码、光标和其他开关。
local M = {}

function M.init(env)
    local config = env.engine.schema.config
    env.target_schema = config:get_string("dict_layout/target_schema")
    env.hotkey = KeyEvent("Control+Shift+E")
    env.switch_names = {}
    for i = 0, config:get_list_size("switches") - 1 do
        local name = config:get_string("switches/@" .. i .. "/name")
        if name and name ~= "dict_comment" then
            table.insert(env.switch_names, name)
        end
    end
end

function M.func(key, env)
    if key:release() or not key:eq(env.hotkey) or not env.target_schema then
        return 2 -- kNoop
    end

    local engine = env.engine
    local context = engine.context
    local input, caret_pos = context.input, context.caret_pos
    local options = {}
    for _, name in ipairs(env.switch_names) do
        options[name] = context:get_option(name)
    end

    -- apply_schema 会重建处理器并清空输入，之后不再访问旧 env。
    engine:apply_schema(Schema(env.target_schema))
    context = engine.context
    for name, value in pairs(options) do
        if context:get_option(name) ~= value then
            context:set_option(name, value)
        end
    end
    if input ~= "" then
        context:push_input(input)
        context.caret_pos = caret_pos
    end
    return 1 -- kAccepted
end

return M
