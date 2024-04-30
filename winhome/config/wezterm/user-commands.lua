local wezterm = require("wezterm")
local wez = require("lib.wez")
local utils = require("lib.utils")
local act = wezterm.action

local M = {}

M.commands = {
  OpenWorkspace = "w:open",
  CreateWorkspace = "w:create",
  Open = "open",
  Start = "start",
  ActivatePaneDirection = "p:activate",
  ResizePaneDirection = "p:resize",
  GetClipboard = "getclip",
}

return {
  [M.commands.OpenWorkspace] = function(window, pane, cmd_context)
    wezterm.log_info("SWITCHING WORKSPACE", cmd_context)
    window:perform_action(
      act.SwitchToWorkspace({
        name = cmd_context.v,
      }),
      pane
    )
  end,

  [M.commands.CreateWorkspace] = function(window, pane, cmd_context)
    wezterm.log_info(cmd_context)
    wez.switch_workspace(cmd_context.v, window, pane)
  end,

  [M.commands.Open] = function(window, pane, cmd_context)
    local wezterm_dir = os.getenv("WEZTERM_CONFIG_DIR")

    local url = utils.read_file(utils.path_join(wezterm_dir, "xdg-open-url"))

    wezterm.log_info("OPENING URL:" .. url)
    if utils.is_windows() then
      wezterm.open_with(url)
    else
      os.execute("open " .. url)
    end
  end,

  [M.commands.Start] = function(window, pane, cmd_context)
    local wezterm_dir = os.getenv("WEZTERM_CONFIG_DIR")
    local url = utils.read_file(utils.path_join(wezterm_dir, "xdg-start"))

    wezterm.log_info("OPENING :" .. url)

    os.execute("start " .. url)
  end,

  [M.commands.ActivatePaneDirection] = function(window, pane, cmd_context)
    wezterm.log_info("ACTIVATE DIRECTION", cmd_context.v)
    window:perform_action({ ActivatePaneDirection = cmd_context.v }, pane)
  end,

  [M.commands.ResizePaneDirection] = function(window, pane, cmd_context)
    wezterm.log_info("RESIZE DIRECTION", cmd_context.v)
    window:perform_action({ AdjustPaneSize = { cmd_context.v, 3 } }, pane)
  end,
}
