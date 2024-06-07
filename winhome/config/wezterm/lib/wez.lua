---@type Wezterm
---@diagnostic disable-next-line: assign-type-mismatch
local wezterm = require("wezterm")
local act = wezterm.action
local mux = wezterm.mux
local u = require("lib.utils")

local M = {}

M.default_layout = function(name)
  return function()
    return {
      name = u.ucfirst(name),
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

function M.run_child_process(args)
  if wezterm.target_triple:find("windows") then
    args = { "wsl.exe", "--exec", table.unpack(args) }
  end

  return wezterm.run_child_process(args)
end

function M.switch_workspace(name, win, pane)
  win:perform_action(
    act.SwitchToWorkspace({
      name = name,
    }),
    pane
  )

  local workspace_win = u.find(mux.all_windows(), function(mux_window)
    return mux_window:get_workspace() == mux.get_active_workspace()
  end)

  return workspace_win
end

function M.load_workspace(name, window, pane)
  wezterm.log_info("Starting workspace ", name)
  local workspace_win = M.switch_workspace(u.ucfirst(name), window, pane)
  -- wezterm.sleep_ms(300)

  local sucess, stdout = M.run_child_process({ "cat", wezterm.GLOBAL.project_path .. "/" .. name .. "/.wezterm.lua" })
  local layout_file = sucess and load(stdout) or M.default_layout(name)

  if layout_file then
    local layout = layout_file()

    if workspace_win then
      M.apply_layout(workspace_win, layout)
    end
  end
end

---@param win Window
---@param layout table
function M.apply_layout(win, layout)
  local main_pane = win:active_pane()
  M.ensure_cwd(main_pane, layout.cwd)

  local current_pane = main_pane
  for _, pane_config in pairs(layout.panes or {}) do
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

function M.kill_wokspace(workspace)
  return function(window, pane, line)
    local success, stdout = wezterm.run_child_process({ "wezterm.exe", "cli", "list", "--format=json" })

    if success then
      local json = wezterm.json_parse(stdout)
      if not json then
        return
      end

      local workspace_panes = u.filter(json, function(v)
        return v.workspace == workspace
      end)

      for _, p in ipairs(workspace_panes) do
        wezterm.run_child_process({ "wezterm.exe", "cli", "kill-pane", "--pane-id=" .. p.pane_id })
      end
    end
  end
end

return M
