---@type Wezterm
---@diagnostic disable-next-line: assign-type-mismatch
local wezterm = require("wezterm")
local act = wezterm.action

local actions = require("actions")
local workspace_switcher = require("lib.workspace-switcher")

return {
  {
    key = "Backspace",
    mods = "SHIFT|ALT",
    action = wezterm.action_callback(function(window, pane)
      window:perform_action(act.ActivateKeyTable({ name = "WS", one_shot = false }), pane)
    end),
  },
  {
    key = [[|]],
    mods = "SHIFT|ALT",
    action = wezterm.action_callback(actions.split_pane("Right")),
  },
  {
    key = "R",
    mods = "SHIFT|ALT",
    action = act.EmitEvent("reload-config-request"),
  },

  {
    key = [[_]],
    mods = "SHIFT|ALT",
    action = wezterm.action_callback(actions.split_pane("Bottom")),
  },
  {
    key = "T",
    mods = "SHIFT|ALT",
    action = wezterm.action_callback(actions.create_new_tab),
  },
  {
    key = "Z",
    mods = "SHIFT|ALT",
    action = act.TogglePaneZoomState,
  },
  {
    key = "LeftArrow",
    mods = "SHIFT|ALT",
    action = act.ActivateTabRelative(-1),
  },
  {
    key = "RightArrow",
    mods = "SHIFT|ALT",
    action = act.ActivateTabRelative(1),
  },
  -- WORKSPACE Management
  {
    key = "Enter",
    mods = "SHIFT|ALT",
    action = wezterm.action_callback(workspace_switcher.workspace_selector),
  },
  {
    key = "Delete",
    mods = "ALT|SHIFT",
    action = wezterm.action_callback(actions.kill_current_wokspace),
  },

  -- move between split panes
}
