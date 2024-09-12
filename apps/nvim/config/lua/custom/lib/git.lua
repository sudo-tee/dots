--- @module 'custom.lib.utils'
local u = lazy_require('custom.lib.utils')

local M = {}

function M.default_branch()
  local cmd_output = vim.fn.system('basename $(git symbolic-ref refs/remotes/origin/HEAD)'):gsub('\n', '')

  return u.just(cmd_output).or_else('main').unwrap()
end

function M.current_branch()
  local cmd_output = vim.b.gitsigns_head or vim.fn.system('git branch --show-current'):gsub('\n', '')

  return u.just(cmd_output).or_else(nil).unwrap()
end

M.current_repo = u.memoize(function()
  local cmd_output = vim.fn.system('git remote get-url origin'):gsub('\n', '')

  return u.just(cmd_output).or_else(nil).unwrap()
end)

M.get_repo_url = function()
  local repo = M.current_repo() or ''

  return repo:gsub(':', '/'):gsub('git@', 'https://')
end

function M.find_nearest_commit_hash()
  local commit_hash_pattern = '\\<[0-9a-f]\\{7,40}\\>'
  vim.cmd('normal! 0')
  vim.fn.search(commit_hash_pattern)
  return vim.fn.matchstr(vim.fn.getline('.'), commit_hash_pattern)
end

return M
