---@class Pane
---@field title string
---@field cwd string|nil -- if nil, it will use the cwd of the parent layout
---@field direction string
---@field size number
---@field command string
---@field domain string|nil -- if nil, it will use CurrentPaneDomain

---@class Tab
---@field name string
---@field cwd string|nil -- if nil, it will use the cwd of the parent layout
---@field command string
---@field domain string|nil -- if nil, it will use CurrentPaneDomain
---@field panes Pane[]|nil

---@class WorkspaceLayout
---@field name string
---@field cwd string
---@field command string
---@field title string
---@field panes Pane[]|nil
---@field tabs Tab[]|nil

---@class WorkspaceManagerOptions
---@field get_layout fun(name: string, cwd: string): WorkspaceLayout
local Opts = {
  ---@diagnostic disable-next-line: assign-type-mismatch
  get_layout = nil,
}

local M = {}

M.default_layout = function(name, cwd)
  ---@return WorkspaceLayout
  return {
    name = name,
    cwd = cwd,
    command = "echo welcome to " .. name,
    title = name,
  }
end

-- Loads a workspace configuration from a .wezterm_layout.lua file in the given path.
-- If the file does not exist or cannot be loaded, a default layout is used.
-- The layout is then applied to the given window.
--- @param name string The name of the workspace to configure.
--- @param path string The path  of the workspace
--- @param window MuxWindow The window where the workspace layout will be applied.
function M.configure_workspace(name, path, window)
  wezterm.log_info("Configuring workspace ", name)

  M.apply_layout(window, Opts.get_layout(name, path) or M.default_layout(name, path))
end

---@param window MuxWindow
---@param layout WorkspaceLayout|Tab
function M.apply_layout(window, layout)
  local main_pane = window:active_pane()

  local current_pane = main_pane
  for _, pane_config in pairs(layout.panes or {}) do
    local cwd = pane_config.cwd or layout.cwd
    current_pane = current_pane:split({
      size = pane_config.size,
      direction = pane_config.direction,
      cwd = cwd,
      domain = pane_config.domain and { DomainName = pane_config.domain } or "CurrentPaneDomain",
    })

    wezterm.emit("workspace-manager/on-pane-created", window, current_pane, pane_config, cwd)

    if pane_config.command then
      (function(pane, command)
        wezterm.time.call_after(0.5, function()
          pane:send_text(command .. "\n")
        end)
      end)(current_pane, pane_config.command)
    end
  end

  for _, tab_config in ipairs(layout.tabs or {}) do
    local cwd = tab_config.cwd or layout.cwd or "~"
    local current_tab = window:spawn_tab({
      cwd = cwd,
      domain = tab_config.domain and { DomainName = tab_config.domain } or "CurrentPaneDomain",
    })

    current_tab:set_title(tab_config.name)
    wezterm.emit("workspace-manager/on-tab-created", window, current_pane, tab_config, cwd)

    M.apply_layout(window, tab_config)
  end

  wezterm.emit("workspace-manager/on-layout-applied", window, main_pane, layout)

  if layout.command then
    main_pane:send_text(layout.command .. "\n")
  end

  main_pane:activate()
end

-- Simple hack to change the cwd of a pane
-- there is a sleep because it gives the time for the pane to be created
-- This is needed over ssh when there is no shell integration or wezterm-mux-server
function M.ensure_cwd(pane, cwd)
  wezterm.sleep_ms(50)
  pane:send_text("cd " .. cwd .. "\n")
  pane:send_text("clear \n")
end

-- Lists all panes in the given workspace.
-- If no workspace is given, the active workspace is used.
--- @param workspace_name string|nil The name of the workspace to list panes from.
--- @return PaneInformation[]|nil
function M.get_workspace_panes(workspace_name)
  workspace_name = workspace_name or wezterm.mux.get_active_workspace()
  local success, stdout = wezterm.run_child_process({ "wezterm", "cli", "list", "--format=json" })

  if success then
    local json = wezterm.json_parse(stdout)
    if not json then
      return
    end

    local workspace_panes = {}
    for _, pane in ipairs(json) do
      if pane.workspace == workspace_name then
        table.insert(workspace_panes, pane)
      end
    end
    return workspace_panes
  end
end

--Kills a pane by its ID.
--- @param pane_id number ID of the pane to kill.
function M.kill_pane_by_id(pane_id)
  local success, _ = wezterm.run_child_process({ "wezterm", "cli", "kill-pane", "--pane-id=" .. pane_id })
  if not success then
    wezterm.log_error("Failed to kill pane with ID " .. pane_id)
  end
end

function M.kill_workspace(workspace_name)
  return function(window)
    workspace_name = workspace_name or wezterm.mux.get_active_workspace()
    local workspace_panes = M.get_workspace_panes(workspace_name) or {}
    for _, pane in ipairs(workspace_panes) do
      M.kill_pane_by_id(pane.pane_id)
    end
  end
end

---@param config Config Wezterm config object
---@param opts WorkspaceManagerOptions
function M.setup(config, opts)
  Opts.get_layout = opts.get_layout
end

return M
