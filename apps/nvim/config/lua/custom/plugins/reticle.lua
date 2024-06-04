return {
  'tummetott/reticle.nvim',
  event = 'LazyFile',
  opts = {
    on_startup = {
      cursorline = true,
      cursorcolumn = false,
    },
    disable_in_diff = false,
    ignore = {
      cursorline = {
        'dashboard',
        'noice',
        'lazy',
        'FTerm',
        '',
      },
      cursorcolumn = {},
    },
  },
}
