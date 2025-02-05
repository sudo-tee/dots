local act = wezterm.action
local mux = wezterm.mux
local u = require("lib.utils")
local map = require("lib.keymap").map
local workspace_manager = require("lib.workspace-manager")
local Frecency = require("lib.frecency")

local WORKSPACE_SWITCHER_KEYTABLE = "WORKSPACE_SWITCHER"
local KEYTABLE_LEGEND =
  " <CR> select | <C-d> kill | <C-n> new | <Esc> cancel | Score:  <C-s> debug | <C-b> boost | <C-r> reset"

---@class WorkspaceSwitcherOptions
---@field get_projects fun(): table<{name: string, path:string, cwd:string}>

local M = {}

local State = {
  projects = nil,
  workspaces = nil,
  switcher_action = nil,
  get_projects = nil,
  debug_scores = false,
  frecency = Frecency:new(),
}

local function format_text(icon, label, color)
  return wezterm.format({ { Foreground = { AnsiColor = color } }, { Text = icon .. " " .. label } })
end

local function create_choice_item(color, icon, name, suffix)
  return { id = name, label = format_text(icon, name .. (suffix or ""), color) }
end

local function list_workspaces()
  local active_workspace = mux.get_active_workspace()
  local items = {}
  for _, ws in ipairs(u.keys(State.workspaces)) do
    table.insert(items, {
      name = ws,
      score = State.frecency:calculate_frecency(ws, active_workspace),
      current = (ws == active_workspace),
      type = "workspace",
    })
  end
  table.sort(items, function(a, b)
    return a.score > b.score
  end)
  return items
end

local function list_projects()
  local items = {}
  for _, project in ipairs(u.keys(State.projects)) do
    if not State.workspaces[project] then
      table.insert(items, { name = project, score = State.frecency:calculate_frecency(project), type = "project" })
    end
  end
  table.sort(items, function(a, b)
    return a.score > b.score
  end)
  return items
end

local function format_workspace_item(item)
  local color = item.current and "Blue" or "White"
  local suffix = item.current and " (current)" or ""
  local icon = "󱂬 "
  local base_item = create_choice_item(color, icon, item.name, suffix)
  if State.debug_scores then
    base_item.label = format_text(icon, item.name .. suffix .. " " .. format_text("", item.score, "Grey"), color)
  end
  return base_item
end

local function format_project_item(item)
  local base_item = create_choice_item("Grey", "  ", item.name, "")
  if State.debug_scores then
    base_item.label = format_text(" ", item.name .. " " .. item.score, "Grey")
  end
  return base_item
end

local function get_choices()
  local choices = {}
  local ws_items = list_workspaces()
  for _, item in ipairs(ws_items) do
    table.insert(choices, format_workspace_item(item))
  end
  local project_items = list_projects()
  for _, item in ipairs(project_items) do
    table.insert(choices, format_project_item(item))
  end
  return choices
end

local function on_item_selected(window, pane, selection)
  if not selection then
    return
  end

  u.switch(State.switcher_action, {
    ["kill"] = function()
      workspace_manager.kill_workspace(selection)(window)
      M.workspace_selector(window, window:active_pane())
    end,
    ["select"] = function()
      M.switch_workspace(window, pane, selection)
    end,
    ["new-workspace"] = function()
      M.create_new_workspace(window, pane)
    end,
    ["toggle-debug"] = function()
      State.debug_scores = not State.debug_scores
      M.workspace_selector(window, pane)
    end,
    ["boost"] = function()
      State.frecency:visit(selection, 5)
      M.workspace_selector(window, pane)
    end,
    ["reset"] = function()
      State.frecency:reset(selection)
      M.workspace_selector(window, pane)
    end,
  })

  State.switcher_action = nil
end

local function keymap(keys, action)
  local forwarded_key = action and "Enter" or keys
  return map(keys, function(window, pane)
    State.switcher_action = action
    window:perform_action(act.PopKeyTable, pane)
    window:perform_action(act.SendKey({ key = forwarded_key }), pane)
  end)
end

local function activate_key_table(window, pane, name)
  if window:active_key_table() == name then
    window:perform_action(act.PopKeyTable, pane)
  end

  window:perform_action(act.ActivateKeyTable({ name = name, one_shot = false }), pane)
end

function M.switch_workspace(window, pane, name)
  local is_new = not State.workspaces[name]
  local project = State.projects[name] or {}
  local path = project.cwd or project.path

  State.frecency:visit(name)

  window:perform_action(act.SwitchToWorkspace({ name = name, spawn = { cwd = path or "~" } }), pane)

  local active_pane = window:active_pane()

  wezterm.emit(
    "workspace-switcher-switched",
    { name = name, path = path, window = active_pane:window(), pane = active_pane, is_new = is_new }
  )
end

---@param window Window
---@param pane Pane
function M.workspace_selector(window, pane)
  State.switcher_action = nil
  State.workspaces = u.index_by(mux.get_workspace_names())
  State.projects = u.index_by(State.get_projects() or {}, "name")

  activate_key_table(window, pane, WORKSPACE_SWITCHER_KEYTABLE)

  window:perform_action(
    act.InputSelector({
      title = "Choose a workspace",
      fuzzy = true,
      fuzzy_description = "Search workspaces: ",
      choices = get_choices(),
      action = wezterm.action_callback(on_item_selected),
    }),
    pane
  )
end

---@param window Window
---@param pane Pane
function M.create_new_workspace(window, pane)
  window:perform_action(
    act.PromptInputLine({
      description = "Enter workspace name:",
      action = wezterm.action_callback(M.switch_workspace),
    }),
    pane
  )
end

---@param config Config
---@param opts WorkspaceSwitcherOptions
function M.setup(config, opts)
  State.get_projects = opts.get_projects

  config.key_tables[WORKSPACE_SWITCHER_KEYTABLE] = {
    keymap("Enter", "select"),
    keymap("<C-d>", "kill"),
    keymap("<C-n>", "new-workspace"),
    keymap("<C-s>", "toggle-debug"),
    keymap("<C-b>", "boost"),
    keymap("<C-r>", "reset"),
    keymap("Escape"),
  }

  wezterm.on("update-key-table-legend/" .. WORKSPACE_SWITCHER_KEYTABLE, function(window, pane)
    window:set_right_status(format_text(wezterm.nerdfonts.fa_keyboard_o, KEYTABLE_LEGEND, "Navy"))
  end)
end

return M
