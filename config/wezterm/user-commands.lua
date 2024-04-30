local wezterm = require("wezterm")
local wez = require("lib.wez")
local act = wezterm.action

local M = {}

M.commands = {
	OpenWorkspace = "w:open",
	CreateWorkspace = "w:create",
}

return {

	[M.commands.OpenWorkspace] = function(window, pane, cmd_context)
		wezterm.log_info("SWITCHING WORKSPACE", cmd_context)
		window:perform_action(
			act.SwitchToWorkspace({
				name = cmd_context.v,
			}),
			pane
		)
	end,

	[M.commands.CreateWorkspace] = function(window, pane, cmd_context)
		wezterm.log_info(cmd_context)
		wez.load_layout(cmd_context.v, window, pane)
	end,
}
