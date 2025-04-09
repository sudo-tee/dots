local M = {}

---@param direction "Right" | "Bottom"
function M.split_pane(direction)
  ---@param window Window
  ---@param pane Pane
  ---@param line string
  return function(window, pane, line)
    local utils = require("lib.utils")
    local cwd = utils.get_pane_path(pane)

    pane:split({
      direction = direction,
      cwd = cwd,
    })

    -- wez.ensure_cwd(new_pane, cwd.path)
  end
end

---@param window Window
---@param pane Pane
---@param line string
function M.create_new_tab(window, pane, line)
  local utils = require("lib.utils")
  local path = utils.get_pane_path(pane)

  window:mux_window():spawn_tab({ cwd = path })
end

---@param window Window
function M.kill_current_wokspace(window)
  local workspace_manager = require("lib.workspace-manager")
  workspace_manager.kill_workspace(window:active_workspace())(window)

  --prompt to select a new workspace
  require("lib.workspace-switcher").workspace_selector(window, window:active_pane())
end

---@param window Window
---@param pane Pane
---@param line string
function M.rename_tab(window, pane, line)
  window:perform_action(
    wezterm.action.PromptInputLine({
      description = "Rename tab:",
      action = wezterm.action_callback(function(window, pane, line)
        if line then
          window:active_tab():set_title(line)
        end
      end),
    }),
    pane
  )
end

return M
