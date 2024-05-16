---@type Wezterm
local wezterm = require("wezterm")

local prog_icons = {
  nvim = wezterm.nerdfonts.custom_neovim,
  ["t watch"] = wezterm.nerdfonts.dev_nodejs_small,
  ["nr dev"] = wezterm.nerdfonts.dev_nodejs_small,
  ["nr start"] = wezterm.nerdfonts.dev_nodejs_small,
  ["ni"] = wezterm.nerdfonts.dev_npm,
  ["title"] = wezterm.nerdfonts.md_format_title,
  ["working_dir"] = wezterm.nerdfonts.oct_terminal,
  ["default_prog"] = wezterm.nerdfonts.md_application,
}

return prog_icons
