local wezterm = require("wezterm")
local actions = require("actions")
local act = wezterm.action

local M = {}

M.key_tables = {
  WS = {
    {
      key = "Enter",
      action = wezterm.action_callback(function(window, pane)
        window:perform_action(act.PopKeyTable, pane)
        window:perform_action(act.SendKey({ key = "Enter" }), pane)
      end),
    },
    {
      key = "Delete",
      action = wezterm.action_callback(function(window, pane)
        -- dont close the key table we use this as an indicator that we want to delete the workspace
        -- This allows to know which element is selected
        window:perform_action(act.SendKey({ key = "Enter" }), pane)
      end),
    },
    {
      key = "n",
      mods = "CTRL",
      action = wezterm.action_callback(function(window, pane)
        window:perform_action(act.PopKeyTable, pane)
        actions.create_new_workspace(window, pane)
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
    legend = "<CR> select | <Del> kill | <C-n> new | <Esc> cancel",
  },
}

return M
