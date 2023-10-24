local wezterm = require("wezterm")
local act = wezterm.action
local mux = wezterm.mux
local u = require("lib.utils")
local smart_splits = require("lib.smart-splits")
local user_commands = require("user-commands")

wezterm.on("user-var-changed", function(window, pane, name, value)
	wezterm.log_info(pane:get_user_vars())
	if name == "uc" then
		local cmd_context = wezterm.json_parse(value)

		wezterm.log_info("DE:", cmd_context)
		user_commands[cmd_context.c](window, pane, cmd_context)
		return
	end
end)

wezterm.on("update-status", function(window, pane)
	-- Workspace name
	local stat = window:active_workspace()
	local stat_color = "#58a6ff"
	-- It's a little silly to have workspace name all the time
	-- Utilize this to display LDR or current key table name
	if window:active_key_table() then
		stat = window:active_key_table()
		stat_color = "#7dcfff"
	end
	if window:leader_is_active() then
		stat = "LDR"
		stat_color = "#bb9af7"
	end

	-- Current working directory
	local basename = function(s)
		-- Nothing a little regex can't fix
		return string.gsub(s, "(.*[/\\])(.*)", "%2")
	end
	-- CWD and CMD could be nil (e.g. viewing log using Ctrl-Alt-l). Not a big deal, but check in case
	local cwd = pane:get_current_working_dir()
	cwd = cwd and basename(cwd) or ""
	-- Current command
	local vars = pane:get_user_vars()
	local cmd = pane:get_foreground_process_name()
	cmd = cmd and basename(cmd)
	cmd = cmd or vars["PROG"] or ""

	-- Time
	local time = wezterm.strftime("%H:%M")

	-- Left status (left of the tab line)
	window:set_left_status(wezterm.format({
		{ Foreground = { Color = stat_color } },
		{ Text = "  " },
		{ Text = wezterm.nerdfonts.oct_table .. "  " .. stat },
		{ Text = " |" },
	}))

	-- Right status
	window:set_right_status(wezterm.format({
		-- Wezterm has a built-in nerd fonts
		-- https://wezfurlong.org/wezterm/config/lua/wezterm/nerdfonts.html
		{ Text = wezterm.nerdfonts.md_folder .. "  " .. cwd },
		{ Text = " | " },
		{ Foreground = { Color = "#e0af68" } },
		{ Text = wezterm.nerdfonts.fa_code .. "  " .. cmd },
	}))
end)

return {
	max_fps = 120,
	window_decorations = "RESIZE",
	use_fancy_tab_bar = false,
	status_update_interval = 1000,
	window_background_opacity = 0.9,
	default_domain = "dev",
	--	hide_tab_bar_if_only_one_tab = true,
	show_tab_index_in_tab_bar = false,
	show_new_tab_button_in_tab_bar = false,
	window_close_confirmation = "NeverPrompt",
	exit_behavior = "Close",
	font = wezterm.font("JetBrains Mono"),
	font_size = 11,
	front_end = "WebGpu",
	webgpu_power_preference = "HighPerformance",
	color_scheme = "Catppuccin Mocha",
	colors = {
		tab_bar = {
			active_tab = {
				bg_color = "#2b2042",
				fg_color = "#ffffff",
			},
		},
	},
	ssh_domains = {
		{
			name = "dev",
			remote_address = "dev",
			username = "francis",
			connect_automatically = true,
			multiplexing = "None",
		},
	},
	window_padding = {
		left = 0,
		right = 0,
		top = 0,
		bottom = 0,
	},
	keys = {
		{
			mods = "ALT",
			key = [[\]],
			action = wezterm.action({
				SplitHorizontal = { domain = "CurrentPaneDomain" },
			}),
		},
		{
			mods = "ALT",
			key = [[-]],
			action = wezterm.action({
				SplitVertical = { domain = "CurrentPaneDomain" },
			}),
		},
		{
			key = "O",
			mods = "CTRL|SHIFT",
			action = wezterm.action_callback(function(window, pane, line)
				local wez = require("lib.wez")
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
								wez.load_layout(id, window, pane)
							end
						end),
						title = "Choose a workspace",
						choices = choices,
						fuzzy = true,
					}),
					pane
				)
			end),
		},
		{
			key = "N",
			mods = "CTRL|SHIFT",
			action = act.PromptInputLine({
				description = wezterm.format({
					{ Attribute = { Intensity = "Bold" } },
					{ Foreground = { AnsiColor = "Fuchsia" } },
					{ Text = "Enter name for new workspace" },
				}),

				action = wezterm.action_callback(function(window, pane, line)
					local wez = require("lib.wez")
					if line then
						wez.switch_workspace(line, window, pane)
					end
				end),
			}),
		},
		{
			key = "K",
			mods = "CTRL|SHIFT",
			action = act.ShowLauncherArgs({ flags = "FUZZY|WORKSPACES" }),
		},
		{
			key = "J",
			mods = "CTRL|SHIFT",
			action = wezterm.action_callback(function(window, pane)
				local wez = require("lib.wez")
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
			end),
		},
		{
			key = "E",
			mods = "CTRL|SHIFT",

			action = wezterm.action_callback(function(w, p) end),
		},
		-- move between split panes
		smart_splits.split_nav("move", "h"),
		smart_splits.split_nav("move", "j"),
		smart_splits.split_nav("move", "k"),
		smart_splits.split_nav("move", "l"),
		smart_splits.split_nav("move", "LeftArrow"),
		smart_splits.split_nav("move", "DownArrow"),
		smart_splits.split_nav("move", "UpArrow"),
		smart_splits.split_nav("move", "RightArrow"),

		-- resize panes
		smart_splits.split_nav("resize", "h"),
		smart_splits.split_nav("resize", "j"),
		smart_splits.split_nav("resize", "k"),
		smart_splits.split_nav("resize", "l"),
		smart_splits.split_nav("resize", "LeftArrow"),
		smart_splits.split_nav("resize", "DownArrow"),
		smart_splits.split_nav("resize", "UpArrow"),
		smart_splits.split_nav("resize", "RightArrow"),
	},
}
