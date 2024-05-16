---@type Wezterm
local wezterm = require("wezterm")
local act = wezterm.action
local mux = wezterm.mux
local u = require("lib.utils")
local wez = require("lib.wez")

local M = {}

---@param direction "Right" | "Bottom"
function M.split_pane(direction)
  ---@param window Window
  ---@param pane Pane
  ---@param line string
  return function(window, pane, line)
    local cwd = pane:get_current_working_dir()

    pane:split({
      direction = direction,
      cwd = cwd.path,
    })

    -- wez.ensure_cwd(new_pane, cwd.path)
  end
end

---@param window Window
---@param pane Pane
---@param line string
function M.create_new_tab(window, pane, line)
  local cwd = pane:get_current_working_dir()
  local _, new_pane = window:mux_window():spawn_tab({})
  -- wez.ensure_cwd(new_pane, cwd.path)
end

---@param window Window
---@param pane Pane
function M.workspace_selector(window, pane)
  local workspaces = mux.get_workspace_names()
  local current_workspace = mux.get_active_workspace()

  local projects_dir = u.path_join(os.getenv("HOME"), ".config", "projects")
  local files = u.map(wezterm.read_dir(projects_dir), function(v)
    return u.basename(v)
  end)

  local project_choices = u.filter(files, function(v)
    local label = u.ucfirst(string.sub(v, 1, -5)):gsub("-", " ")
    return not (u.starts_with(label, "_") or u.starts_with(label, ".") or u.contains(workspaces, label))
  end)

  local choices = {}

  for _, ws in ipairs(workspaces) do
    local is_current = (ws == current_workspace)
    local color = is_current and "Blue" or "White"
    local label = is_current and ws .. " (current)" or ws

    table.insert(choices, { id = ws, label = wezterm.format(u.format_label(label, color)) })
  end

  for _, file in ipairs(project_choices) do
    local label = u.ucfirst(string.sub(file, 1, -5)):gsub("-", " ")
    table.insert(choices, { id = file, label = wezterm.format(u.format_label(label, "Grey")) })
  end

  table.insert(choices, { id = "new-workspace", label = "💫 [New workspace]" })

  window:perform_action(act.ActivateKeyTable({ name = "WS", one_shot = false }), pane)

  window:perform_action(
    act.InputSelector({
      action = wezterm.action_callback(function(window, pane, id)
        local active_key_table = window:active_key_table()

        if not id then
          return
        end

        if active_key_table == "WS" then
          window:perform_action(act.PopKeyTable, pane)
          M.kill_wokspace(id)()
          M.workspace_selector(window, pane)
          return
        end

        if id == "new-workspace" then
          M.create_new_workspace(window, pane)
        elseif u.contains(project_choices, u.basename(id)) then
          wez.load_workspace(id, window, pane)
        else
          wez.switch_workspace(id, window, pane)
        end
      end),
      title = "Choose a workspace",
      choices = choices,
      fuzzy = true,
      fuzzy_description = " > ",
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
  return M.kill_wokspace(window:active_workspace())(window, pane, line)
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
