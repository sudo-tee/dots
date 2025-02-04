--- Lazy require a module
---@diagnostic disable-next-line: duplicate-set-field
function _G.lazy_require(module)
  local mod = nil
  return type(package.loaded[module]) == 'table' and package.loaded[module]
    or setmetatable({}, {
      __index = function(_, key)
        mod = mod or require(module)
        return mod[key]
      end,
    })
end

_G.reload = function(...)
  return require('plenary.reload').reload_module(...)
end

_G.re_require = function(name)
  M.reload(name)
  return require(name)
end
