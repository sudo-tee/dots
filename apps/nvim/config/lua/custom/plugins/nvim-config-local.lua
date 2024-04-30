return {
  'klen/nvim-config-local',
  event = 'VimEnter',
  opts = {
    config_files = { '.nvim.lua', '.nvimrc', '.exrc' },
  },
}
