return {
	unix_domains = {
		{
			name = "dev",
			-- Override the default path to match the default on the host win32
			-- filesystem.  This will allow the host to connect into the guest
			-- container.
			--			socket_path = "/run/user/1000/wezterm/sock",
			-- NTFS permissions will always be "wrong", so skip that check
			skip_permissions_check = true,
		},
	},
}
