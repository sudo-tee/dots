---@type Wezterm
local wezterm = require("wezterm")
local act = wezterm.action

local actions = require("actions")
local smart_splits = require("lib.smart-splits")

return {
  {
    key = "Backspace",
    mods = "SHIFT|ALT",
    action = wezterm.action_callback(function(window, pane)
      window:perform_action(act.ActivateKeyTable({ name = "WS", one_shot = false }), pane)
    end),
  },
  {
    key = "?",
    mods = "SHIFT|ALT",
    action = wezterm.action_callback(function(window, pane)
      local wez = require("lib.wez")

      local _, stdout, _ = window:perform_action(
        act.SpawnCommandInNewTab({
          args = { "/usr/bin/ppp" },
        }),
        pane
      )
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
    action = wezterm.action_callback(actions.workspace_selector),
  },
  {
    key = "J",
    mods = "SHIFT|ALT",
    action = wezterm.action_callback(actions.workspace_selector),
  },
  {
    key = "Delete",
    mods = "ALT|SHIFT",
    action = wezterm.action_callback(actions.kill_current_wokspace),
  },
  -- move between split panes
  smart_splits.split_nav("move", "h"),
  smart_splits.split_nav("move", "j"),
  smart_splits.split_nav("move", "k"),
  smart_splits.split_nav("move", "l"),
  smart_splits.split_nav("move", "LeftArrow"),
  smart_splits.split_nav("move", "DownArrow"),
  smart_splits.split_nav("move", "UpArrow"),
  smart_splits.split_nav("move", "RightArrow"),

  -- resize panes
  smart_splits.split_nav("resize", "h"),
  smart_splits.split_nav("resize", "j"),
  smart_splits.split_nav("resize", "k"),
  smart_splits.split_nav("resize", "l"),
  smart_splits.split_nav("resize", "LeftArrow"),
  smart_splits.split_nav("resize", "DownArrow"),
  smart_splits.split_nav("resize", "UpArrow"),
  smart_splits.split_nav("resize", "RightArrow"),
}
