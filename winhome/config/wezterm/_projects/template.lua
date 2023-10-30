return {
	name = "My app",
	cwd = "/home/francis/Projects/MyApp",
	expose_command = true,
	command = "nvim",
	panes = {
		{
			direction = "Bottom",
			size = 0.2,
			command = "nr start",
		},
		{
			direction = "Right",
			size = 0.5,
			command = "",
		},
	},
}
