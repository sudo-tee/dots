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

function M.kill_current_wokspace(window, pane, line)
  local wez = require("lib.wez")
  return wez.kill_wokspace(window:active_workspace())(window, pane, line)
end

return M
