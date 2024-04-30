local wezterm = require("wezterm")
local act = wezterm.action
local mux = wezterm.mux
local u = require("lib.utils")

local M = {}

function M.switch_workspace(name, win, pane)
	win:perform_action(
		act.SwitchToWorkspace({
			name = name,
		}),
		pane
	)

	wezterm.sleep_ms(1000)

	local workspace_win = u.find(mux.all_windows(), function(mux_window)
		return mux_window:get_workspace() == mux.get_active_workspace()
	end)

	return workspace_win
end

function M.load_layout(name, window, pane)
	local projects_dir = u.path_join(os.getenv("HOME"), ".config", "projects")
	local path = u.path_join(projects_dir, name)

	local layout_file = loadfile(path)
	wezterm.log_info(path, layout_file)
	if layout_file then
		local layout = layout_file()

		local workspaces = mux.get_workspace_names()
		local workspace_exists = u.contains(workspaces, layout.name)

		wezterm.log_info("Starting workspace ", layout.name)

		local workspace_win = M.switch_workspace(layout.name, window, pane)

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

	wezterm.time.call_after(1, function()
		main_pane:send_text("cd " .. layout.cwd .. "\n")
		main_pane:send_text(layout.command .. "\n")
	end)

	local current_pane = main_pane
	for _, pane_config in pairs(layout.panes) do
		current_pane = current_pane:split({
			size = pane_config.size,
			direction = pane_config.direction,
		})
		pane_config.pane = current_pane
	end

	wezterm.time.call_after(1, function()
		for _, pane_config in pairs(layout.panes) do
			local cwd = pane_config.cwd or layout.cwd

			pane_config.pane:send_text("cd " .. cwd .. "\n")
			pane_config.pane:send_text(pane_config.command .. "\n")
		end
	end)

	main_pane:activate()
end
return M
