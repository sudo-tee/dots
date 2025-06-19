local M = {}

local _hooks = {}

---@enum HookName
M.names = {
  ['move_cursor_right'] = 'move_cursor_right',
  ['move_cursor_left'] = 'move_cursor_left',
  ['move_cursor_down'] = 'move_cursor_down',
  ['move_cursor_up'] = 'move_cursor_up',
}

--- Registers a handler function for a named hook.
--- @param hook_name (HookName) The name of the hook
--- @param handler (function) The handler function to register
function M.register_hook(hook_name, handler)
  if type(handler) ~= 'function' then
    error('Handler must be a function')
  end
  _hooks[hook_name] = _hooks[hook_name] or {}
  table.insert(_hooks[hook_name], handler)
end

--- Executes handlers registered to the hook name until one returns true.
--- Returns the return value of the handler that returns true, or nil
--- @param hook_name (HookName) The name of the hook
--- @param ... (any) Arguments passed to hook handlers
function M.run_hook(hook_name, ...)
  local handlers = _hooks[hook_name]
  if not handlers then
    return nil
  end
  for _, handler in ipairs(handlers) do
    local ok, result = pcall(handler, ...)
    if ok and result then
      return result
    end
  end
  return nil
end

return M
