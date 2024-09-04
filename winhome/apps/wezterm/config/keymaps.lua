local act = wezterm.action
local actions = require("actions")
local map = require("lib.keymap").map
local workspace_switcher = require("lib.workspace-switcher")
local u = require("lib.utils")

return {
  map("<S-A-|>", actions.split_pane("Right")),
  map("<S-A-|>", actions.split_pane("Right")),
  map("<S-A-_>", actions.split_pane("Bottom")),
  map("<S-A-T>", actions.create_new_tab),
  map("<S-A-R>", actions.rename_tab),
  map("<S-A-Z>", act.TogglePaneZoomState),
  map("<S-A-LeftArrow>", act.ActivateTabRelative(-1)),
  map("<S-A-RightArrow>", act.ActivateTabRelative(1)),
  map("<S-A-Enter>", workspace_switcher.workspace_selector),
  map("<S-A-Delete>", actions.kill_current_wokspace),
  map("<S-A-L>", act.ShowDebugOverlay),
  map("<S-A-C>", act.ShowDebugOverlay),
  map("<S-A-W>", act.CloseCurrentPane({ confirm = true })),
}
