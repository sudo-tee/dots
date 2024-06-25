---@type Wezterm
---@diagnostic disable-next-line: assign-type-mismatch
local wezterm = require("wezterm")

-- simple hack for my nvim print plugin which uses print and vim.inspect
_G.print = function(...)
  wezterm.log_info("\n===============================")
  wezterm.log_info(...)
  wezterm.log_info("\n===============================")
end

_G.vim = {}
function _G.vim.inspect(x)
  return x
end

_G.wezterm = wezterm

wezterm.GLOBAL.project_path = "/home/francis/Projects/"

wezterm.GLOBAL.wsl_project_path = "\\\\wsl$\\Ubuntu\\home\\francis\\Projects\\"
