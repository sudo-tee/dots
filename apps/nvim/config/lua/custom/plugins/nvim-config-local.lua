return {
  'klen/nvim-config-local',
  priority = 999, -- make sure to load this before all the other start plugins
  opts = {
    config_files = { '.nvim.lua', '.nvimrc', '.exrc' },
  },
}
