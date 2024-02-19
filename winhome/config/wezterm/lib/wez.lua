local wezterm = require("wezterm")
local act = wezterm.action
local mux = wezterm.mux
local u = require("lib.utils")

local M = {}

function M.switch_workspace(name, win, pane, layout)
  win:perform_action(
    act.SwitchToWorkspace({
      name = name,
      -- spawn = {
      --   cwd = layout and layout.cwd or "~",
      -- },
    }),
    pane
  )

  local workspace_win = u.find(mux.all_windows(), function(mux_window)
    return mux_window:get_workspace() == mux.get_active_workspace()
  end)

  return workspace_win
end

function M.load_workspace(name, window, pane)
  local projects_dir = u.path_join(os.getenv("HOME"), ".config", "projects")
  local path = u.path_join(projects_dir, name)

  local layout_file = loadfile(path)
  if layout_file then
    local layout = layout_file()

    local workspaces = mux.get_workspace_names()
    local workspace_exists = u.contains(workspaces, layout.name)

    wezterm.log_info("Starting workspace ", layout.name)

    local workspace_win = M.switch_workspace(layout.name, window, pane, layout)
    wezterm.sleep_ms(300)

    if workspace_exists then
      return
    end

    if workspace_win then
      M.apply_layout(workspace_win, layout)
    end
  end
end

function M.apply_layout(win, layout)
  local main_pane = win:active_pane()

  local current_pane = main_pane
  for _, pane_config in pairs(layout.panes) do
    local cwd = pane_config.cwd or layout.cwd
    current_pane = current_pane:split({
      size = pane_config.size,
      direction = pane_config.direction,
      cwd = cwd,
    })

    M.ensure_cwd(current_pane, cwd)

    wezterm.sleep_ms(100)
    current_pane:send_text(pane_config.command .. "\n")
  end

  M.ensure_cwd(main_pane, layout.cwd)

  wezterm.sleep_ms(100)
  main_pane:send_text(layout.command .. "\n")
  main_pane:activate()
end

-- Simple hack to change the cwd of a pane
-- there is a sleep because it gives the time for the pane to be created
-- This is needed over ssh when there is no shell integration or wezterm-mux-server
function M.ensure_cwd(pane, cwd)
  wezterm.sleep_ms(100)
  pane:send_text("cd " .. cwd .. "\n")
  pane:send_text("clear \n")
end

return M
