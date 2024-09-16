return {
	name = "Dotfiles",
	cwd = "/home/francis/dots",
	command = "nvim",
	title = "editor",
	panes = {},
	tabs = {
		{
			name = "work_dots",
			cwd = "/home/francis/work-dots",
			command = "sleep 1 && nvim",
			title = "editor",
			panes = {},
		},
	},
}
