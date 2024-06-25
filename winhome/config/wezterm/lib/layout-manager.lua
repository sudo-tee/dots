---@type Wezterm
---@diagnostic disable-next-line: assign-type-mismatch
local wezterm = require("wezterm")
local u = require("lib.utils")

local H = {}

H.default_layout = function(name)
  return function()
    return {
      name = name,
      cwd = wezterm.GLOBAL.project_path .. "/" .. name,
      command = "nvim",
      title = "editor",
      panes = {
        {
          title = "watch",
          direction = "Bottom",
          size = 0.1,
          cwd = wezterm.GLOBAL.project_path .. "/" .. name,
          command = "t watch",
        },
        {
          title = "shell",
          direction = "Right",
          size = 0.5,
          command = "",
        },
      },
    }
  end
end

local M = {}

return M
