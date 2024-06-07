---@type Wezterm
---@diagnostic disable-next-line: assign-type-mismatch
local wezterm = require("wezterm")

local act = wezterm.action
local mux = wezterm.mux
local u = require("lib.utils")
local wez = require("lib.wez")

local switch = u.switch

local file_to_label = function(file)
  return u.ucfirst(file):gsub("-", " ")
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
    local name = file_to_label(v)
    return not (u.contains(workspaces, name) or name == current_ws)
  end)
end

local M = {}

function M.refresh_project_list()
  local _, stdout = wez.run_child_process({ "ls", "-I", "_*", "/home/francis/Projects/" })
  local projects = wezterm.split_by_newlines(stdout)
  wezterm.GLOBAL.projects = { list = projects }
end

function M.get_projects()
  if not wezterm.GLOBAL.projects then
    M.refresh_project_list()
  end

  -- wezterm globals are userdata type, so we convert it
  local projects_dir = {}
  for _, project_name in ipairs(wezterm.GLOBAL.projects.list) do
    projects_dir[#projects_dir + 1] = project_name
  end
  return projects_dir
end

---@param window Window
---@param pane Pane
function M.workspace_selector(window, pane)
  wezterm.GLOBAL.ws_switcher_action = nil

  local current_ws = mux.get_active_workspace()
  local workspaces = filter_workspaces(mux.get_workspace_names(), current_ws)

  local unopened_projects = filter_projects(M.get_projects(), workspaces, current_ws)

  local choices = {
    { id = current_ws, label = format_label("▶  " .. current_ws .. " (current)", "Blue") },
  }

  for _, ws in ipairs(workspaces) do
    choices[#choices + 1] = { id = ws, label = "󱂬  " .. format_label(ws, "White") }
  end

  for _, file in ipairs(unopened_projects) do
    choices[#choices + 1] = { id = file, label = "   " .. format_label(file_to_label(file), "Grey") }
  end

  window:perform_action(act.ActivateKeyTable({ name = "WS", one_shot = false }), pane)

  window:perform_action(
    act.InputSelector({
      action = wezterm.action_callback(function(window, pane, id)
        window:perform_action(act.PopKeyTable, pane)
        if not id then
          return
        end

        local action = id == "new-workspace" and "new-workspace" or wezterm.GLOBAL.ws_switcher_action
        local suffix = action == "select" and u.contains(unopened_projects, id) and "-load" or ""

        switch(action .. suffix, {
          ["kill"] = function()
            wez.kill_wokspace(id)(window, pane)
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
          ["refresh"] = function()
            M.refresh_project_list()
            M.workspace_selector(window, pane)
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
  return wez.kill_wokspace(window:active_workspace())(window, pane, line)
end

function M.setup(config, custom_config)
  config.key_tables = config.key_tables or {}
  config.key_tables.WS = {
    {
      key = "Enter",
      action = wezterm.action_callback(function(window, pane)
        wezterm.GLOBAL.ws_switcher_action = "select"
        window:perform_action(act.PopKeyTable, pane)
        window:perform_action(act.SendKey({ key = "Enter" }), pane)
      end),
    },
    {
      key = "d",
      mods = "CTRL",
      action = wezterm.action_callback(function(window, pane)
        wezterm.GLOBAL.ws_switcher_action = "kill"
        window:perform_action(act.PopKeyTable, pane)
        window:perform_action(act.SendKey({ key = "Enter" }), pane)
      end),
    },
    {
      key = "n",
      mods = "CTRL",
      action = wezterm.action_callback(function(window, pane)
        wezterm.GLOBAL.ws_switcher_action = "new-workspace"
        window:perform_action(act.PopKeyTable, pane)
        window:perform_action(act.SendKey({ key = "Enter" }), pane)
      end),
    },
    {
      key = "r",
      mods = "CTRL",
      action = wezterm.action_callback(function(window, pane)
        wezterm.GLOBAL.ws_switcher_action = "refresh"
        window:perform_action(act.PopKeyTable, pane)
        window:perform_action(act.SendKey({ key = "Enter" }), pane)
      end),
    },
    -- Cancel the mode by pressing escape
    {
      key = "Escape",
      action = wezterm.action_callback(function(window, pane)
        window:perform_action(act.PopKeyTable, pane)
        window:perform_action(act.SendKey({ key = "Escape" }), pane)
      end),
    },
  }

  custom_config.key_tables_details = custom_config.key_tables_details or {}
  custom_config.key_tables_details.WS = {
    title = "",
    legend = "<CR> select | <C-d> kill | <C-n> new | <C-r> refresh | <Esc> cancel",
  }
end

wezterm.on("gui-startup", function()
  M.refresh_project_list()
end)

return M
