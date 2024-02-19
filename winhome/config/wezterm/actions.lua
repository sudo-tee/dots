local wezterm = require("wezterm")
local act = wezterm.action
local mux = wezterm.mux
local u = require("lib.utils")
local wez = require("lib.wez")
local print = wezterm.log_info

local M = {}

---@param direction "Right" | "Bottom"
function M.split_pane(direction)
  return function(window, pane, line)
    local cwd = pane:get_current_working_dir()

    local new_pane = pane:split({
      direction = direction,
      cwd = cwd.path,
    })

    wez.ensure_cwd(new_pane, cwd.path)
  end
end

function M.create_new_tab(window, pane, line)
  local cwd = pane:get_current_working_dir()
  local _, new_pane = window:mux_window():spawn_tab({})
  wez.ensure_cwd(new_pane, cwd.path)
end

function M.switch_to_open_workspace(window, pane)
  local workspaces = mux.get_workspace_names()
  local current_workspace = mux.get_active_workspace()

  local choices = {}

  for _, ws in ipairs(workspaces) do
    if ws ~= current_workspace then
      table.insert(choices, { id = ws, label = ws })
    end
  end

  window:perform_action(
    act.InputSelector({
      action = wezterm.action_callback(function(window, pane, id)
        if id then
          wez.switch_workspace(id, window, pane)
        end
      end),
      title = "Choose a workspace",
      choices = choices,
      fuzzy = true,
    }),
    pane
  )
end

function M.open_project_workspace(window, pane, line)
  local projects_dir = u.path_join(os.getenv("HOME"), ".config", "projects")

  local files = wezterm.read_dir(projects_dir)
  local choices = {}

  for _, file in ipairs(files) do
    local file_name = u.basename(file)
    local label = string.sub(file_name, 1, -5)
    if label ~= "_template" then
      table.insert(choices, { id = file_name, label = label })
    end
  end

  window:perform_action(
    act.InputSelector({
      action = wezterm.action_callback(function(window, pane, id, label)
        if id or label then
          wez.load_workspace(id, window, pane)
        end
      end),
      title = "Choose a workspace",
      choices = choices,
      fuzzy = true,
    }),
    pane
  )
end

function M.create_new_workspace(window, pane, line)
  window:perform_action(
    act.PromptInputLine({
      description = wezterm.format({
        { Attribute = { Intensity = "Bold" } },
        { Foreground = { AnsiColor = "Fuchsia" } },
        { Text = "Enter name for new workspace" },
      }),

      action = wezterm.action_callback(function(window, pane, text)
        if text then
          wez.switch_workspace(text, window, pane)
        end
      end),
    }),
    pane
  )
end

function M.kill_current_wokspace(window, pane, line)
  local success, stdout = wezterm.run_child_process({ "wezterm.exe", "cli", "list", "--format=json" })

  if success then
    local json = wezterm.json_parse(stdout)
    if not json then
      return
    end

    local workspace_panes = u.filter(json, function(v)
      return v.workspace == window:active_workspace()
    end)

    for _, p in ipairs(workspace_panes) do
      wezterm.run_child_process({ "wezterm.exe", "cli", "kill-pane", "--pane-id=" .. p.pane_id })
    end
  end
end

return M
