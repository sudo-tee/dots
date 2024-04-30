--- @module 'custom.lib.utils'
local u = lazy_require('custom.lib.utils')

local M = {}

function M.default_branch()
  local cmd_output = vim.fn.system('basename $(git symbolic-ref refs/remotes/origin/HEAD)'):gsub('\n', '')

  return u.some(cmd_output).or_else('main')
end

function M.current_branch()
  local cmd_output = vim.fn.system('git branch --show-current'):gsub('\n', '')

  return u.some(cmd_output).or_else(nil)
end

function M.current_repo()
  local cmd_output = vim.fn.system('git remote get-url origin'):gsub('\n', '')

  return u.some(cmd_output).or_else(nil)
end

return M
