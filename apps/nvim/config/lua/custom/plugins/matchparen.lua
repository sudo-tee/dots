-- this plugin replace the disabled matchparen because it is faster than the default matchparen
return {
  'monkoose/matchparen.nvim',
  event = 'VeryLazy',
  opts = {
    -- on_startup = true, -- Should it be enabled by default
    -- hl_group = 'MatchParen', -- highlight group of the matched brackets
    -- augroup_name = 'matchparen', -- almost no reason to touch this unless there is already augroup with such name
    -- debounce_time = 100, -- debounce time in milliseconds for rehighlighting of brackets.
  },
}
