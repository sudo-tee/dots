---@type Wezterm
local wezterm = require("wezterm")
local act = wezterm.action
local mux = wezterm.mux
local u = require("lib.utils")
local wez = require("lib.wez")

local switch = u.switch

local file_to_label = function(file)
  return u.ucfirst(u.strip_extension(file)):gsub("-", " ")
end
local function format_label(label, color)
  return wezterm.format(u.format_label(label, color))
end

local function filter_workspaces(workspaces, current_ws)
  return u.filter(workspaces, function(w)
    return w ~= current_ws
  end)
end

local function filter_projects(files, workspaces, current_ws)
  return u.filter(files, function(v)
    local label = file_to_label(v)
    return not (
      u.starts_with(label, "_")
      or u.starts_with(label, ".")
      or u.contains(workspaces, label)
      or label == current_ws
    )
  end)
end

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
  wezterm.GLOBAL.ws_switcher_action = nil

  local current_ws = mux.get_active_workspace()
  local workspaces = filter_workspaces(mux.get_workspace_names(), current_ws)

  local projects_dir = u.path_join(os.getenv("HOME"), ".config", "projects")
  local unopened_projects = filter_projects(u.get_files(projects_dir), workspaces, current_ws)

  local choices = {
    { id = current_ws, label = format_label("▶ " .. current_ws .. " (current)", "Blue") },
  }

  for _, ws in ipairs(workspaces) do
    choices[#choices + 1] = { id = ws, label = "  " .. format_label(ws, "White") }
  end

  for _, file in ipairs(unopened_projects) do
    choices[#choices + 1] = { id = file, label = "  " .. format_label(file_to_label(file), "Grey") }
  end

  choices[#choices + 1] = { id = "new-workspace", label = "[NEW WORKSPACE]" }

  window:perform_action(act.ActivateKeyTable({ name = "WS", one_shot = false }), pane)

  window:perform_action(
    act.InputSelector({
      action = wezterm.action_callback(function(window, pane, id)
        window:perform_action(act.PopKeyTable, pane)
        if not id then
          return
        end

        local action = id == "new-workspace" or wezterm.GLOBAL.ws_switcher_action
        local suffix = action == "select" and u.contains(unopened_projects, u.basename(id)) and "-load" or ""

        switch(action .. suffix, {
          ["kill"] = function()
            M.kill_wokspace(id)(window, pane)
            M.workspace_selector(window, pane)
          end,
          ["select"] = function()
            wez.switch_workspace(id, window, pane)
          end,
          ["select-load"] = function()
            wez.load_workspace(id, window, pane)
          end,
          ["new-workspace"] = function()
            M.create_new_workspace(window, pane, id)
          end,
        })

        wezterm.GLOBAL.ws_switcher_action = nil
      end),
      title = "Choose a workspace",
      choices = choices,
      fuzzy = true,
      fuzzy_description = " Choose workspace  🔎 ",
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
