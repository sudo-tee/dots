local hollow = _G.hollow

hollow.config.set({
  window_titlebar_show = false,
  theme = 'kanagawa-wave',
  default_domain = 'UbuntuWSL',
  fonts = {
    family = 'Rec Mono Duotone',
    size = 14.5,
  },
  workspace = {
    default_layout = 'default',
  },
  --watch_dirs = {
  --	"\\\\wsl$\\Ubuntu\\home\\francis\\Projects\\_stuff\\hollow",
  --},
})

hollow.ui.workspace.configure({
  sources = {
    {
      name = 'Ubuntu',
      domain = 'UbuntuWSL',
      cwd_resolver = 'wsl_unc',
      roots = {
        '\\\\wsl$\\Ubuntu\\home\\francis\\Projects',
      },
    },
  },
  filter_item = function(item)
    local basename = hollow.util.basename(item.cwd)
    return basename and basename:sub(1, 1) ~= '_'
  end,
})

hollow.plugins.setup({
  plugins = {
    'C:\\Users\\fbelanger\\smart-splits',
  },
})

hollow.keymap.set('<S-A-Enter>', 'workspace_switcher')
