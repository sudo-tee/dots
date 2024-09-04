local M = {}

local modifiers = { ["C"] = "CTRL", ["S"] = "SHIFT", ["A"] = "ALT", ["M"] = "META" }

function M.parse_key_combination(keys)
  local mod, key = keys:match("<(.+)-(.+)>")
  local mods = {}
  if mod and key then
    for k, v in pairs(modifiers) do
      if mod:find(k) then
        table.insert(mods, v)
      end
    end
    mod = table.concat(mods, "|"):gsub("-", "")
    key = key:gsub("-", "")
  else
    mod = nil
    key = keys
  end
  return mod, key
end

-- Map an action using (n)vim-like syntax
---@param keys string
---@param action ActionCallback | KeyAssignmentAction
function M.map(keys, action)
  local mod, key = M.parse_key_combination(keys)

  return {
    key = key,
    mods = mod,
    action = type(action) == "function" and wezterm.action_callback(action) or action,
  }
end

return M
