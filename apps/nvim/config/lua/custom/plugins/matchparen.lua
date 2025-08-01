-- this plugin replace the disabled matchparen because it is faster than the default matchparen
return {
  'monkoose/matchparen.nvim',
  event = 'VeryLazy',
  opts = {
    hl_group = 'MatchParen', -- highlight group of the matched brackets
    debounce_time = 100, -- debounce time in milliseconds for rehighlighting of brackets.
  },
}
