---@type Wezterm
local wezterm = require("wezterm")

local act = wezterm.action

local M = {}

M.key_tables = {
  WS = {
    {
      key = "Enter",
      action = wezterm.action_callback(function(window, pane)
        wezterm.GLOBAL.ws_switcher_action = "select"
        window:perform_action(act.PopKeyTable, pane)
        window:perform_action(act.SendKey({ key = "Enter" }), pane)
      end),
    },
    {
      key = "d",
      mods = "CTRL",
      action = wezterm.action_callback(function(window, pane)
        wezterm.GLOBAL.ws_switcher_action = "kill"
        window:perform_action(act.PopKeyTable, pane)
        window:perform_action(act.SendKey({ key = "Enter" }), pane)
      end),
    },
    {
      key = "n",
      mods = "CTRL",
      action = wezterm.action_callback(function(window, pane)
        wezterm.GLOBAL.ws_switcher_action = "new-workspace"
        window:perform_action(act.PopKeyTable, pane)
        window:perform_action(act.SendKey({ key = "Enter" }), pane)
      end),
    },
    {
      key = "r",
      mods = "CTRL",
      action = wezterm.action_callback(function(window, pane)
        wezterm.GLOBAL.ws_switcher_action = "refresh"
        window:perform_action(act.PopKeyTable, pane)
        window:perform_action(act.SendKey({ key = "Enter" }), pane)
      end),
    },
    -- Cancel the mode by pressing escape
    {
      key = "Escape",
      action = wezterm.action_callback(function(window, pane)
        window:perform_action(act.PopKeyTable, pane)
        window:perform_action(act.SendKey({ key = "Escape" }), pane)
      end),
    },
  },
}

M.details = {
  WS = {
    title = "",
    legend = "<CR> select | <C-d> kill | <C-n> new | <C-r> refresh | <Esc> cancel",
  },
}

return M
