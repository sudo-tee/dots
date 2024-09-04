local utils = require("lib.utils")

local M = {}

M.commands = {
  Open = "open",
  Start = "start",
  ActivatePaneDirection = "p:activate",
  ResizePaneDirection = "p:resize",
}

return {

  [M.commands.Open] = function(window, pane, cmd_context)
    local home = os.getenv("HOME")

    local url = utils.read_file(home .. "\\.config\\wezterm\\xdg-open-url")

    wezterm.log_info("OPENING URL:" .. url)

    if url then
      wezterm.open_with(url)
    end
  end,

  [M.commands.Start] = function(window, pane, cmd_context)
    local home = os.getenv("HOME")
    local url = utils.read_file(home .. "\\.config\\wezterm\\xdg-start")

    wezterm.log_info("OPENING :" .. url)

    os.execute("start " .. url)
  end,

  [M.commands.ActivatePaneDirection] = function(window, pane, cmd_context)
    window:perform_action({ ActivatePaneDirection = cmd_context.v }, pane)
  end,

  [M.commands.ResizePaneDirection] = function(window, pane, cmd_context)
    window:perform_action({ AdjustPaneSize = { cmd_context.v, 3 } }, pane)
  end,
}
