---@type Wezterm
local wezterm = require("wezterm")

-- simple hack for my nvim print plugin which uses print and vim.inspect
_G.print = wezterm.log_info
_G.vim = {}
function _G.vim.inspect(x)
  return x
end

wezterm.GLOBAL.project_path = "/home/francis/Projects"
