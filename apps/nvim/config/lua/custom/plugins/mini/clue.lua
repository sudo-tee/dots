local M = {}

local u = require('custom.lib.utils')

M.setup = function()
  local miniclue = require('mini.clue')
  miniclue.setup({
    triggers = {
      -- Leader triggers
      { mode = 'n', keys = '<Leader>' },
      { mode = 'x', keys = '<Leader>' },
      { mode = 'n', keys = '<Localleader>' },
      { mode = 'x', keys = '<LocalLeader>' },

      -- Built-in completion
      { mode = 'i', keys = '<C-x>' },

      -- `g` key
      { mode = 'n', keys = 'g' },
      { mode = 'x', keys = 'g' },

      -- Marks
      { mode = 'n', keys = "'" },
      { mode = 'n', keys = '`' },
      { mode = 'x', keys = "'" },
      { mode = 'x', keys = '`' },

      -- Registers
      { mode = 'n', keys = '"' },
      { mode = 'x', keys = '"' },
      { mode = 'i', keys = '<C-r>' },
      { mode = 'c', keys = '<C-r>' },

      -- Window commands
      { mode = 'n', keys = '<C-w>' },

      -- `z` key
      { mode = 'n', keys = 'z' },
      { mode = 'x', keys = 'z' },

      { mode = 'n', keys = 'v' },
      { mode = 'x', keys = 'v' },
      { mode = 'n', keys = 'c' },
      { mode = 'n', keys = 'd' },

      { mode = 'n', keys = ']' },
      { mode = 'x', keys = ']' },
      { mode = 'n', keys = '[' },
      { mode = 'x', keys = '[' },
    },

    window = {
      delay = 300,
    },
    clues = {
      {
        { mode = 'n', keys = '<Leader>T', desc = '+Tab' },
        { mode = 'n', keys = '<Leader>b', desc = '+Buffer' },
        { mode = 'n', keys = '<Leader>c', desc = '+Code' },
        { mode = 'n', keys = '<Leader>cc', desc = '+Copilot Chat' },
        { mode = 'n', keys = '<Leader>cf', desc = '+Function' },
        { mode = 'n', keys = '<Leader>f', desc = '+File' },
        { mode = 'n', keys = '<Leader>fy', desc = '+Yank' },
        { mode = 'n', keys = '<Leader>g', desc = '+Git' },
        { mode = 'n', keys = '<Leader>gb', desc = '+Branch' },
        { mode = 'n', keys = '<Leader>gc', desc = '+Log' },
        { mode = 'n', keys = '<Leader>gd', desc = '+Diff' },
        { mode = 'n', keys = '<Leader>gf', desc = '+File' },
        { mode = 'n', keys = '<Leader>gh', desc = '+Hunk' },
        { mode = 'n', keys = '<Leader>gl', desc = '+Gitlab' },
        { mode = 'n', keys = '<Leader>gp', desc = '+Push' },
        { mode = 'n', keys = '<Leader>gr', desc = '+Rebase' },
        { mode = 'n', keys = '<Leader>j', desc = '+Jump' },
        { mode = 'n', keys = '<Leader>m', desc = '+Macro' },
        { mode = 'n', keys = '<Leader>n', desc = '+Notes' },
        { mode = 'n', keys = '<Leader>p', desc = '+Project' },
        { mode = 'n', keys = '<Leader>pk', desc = '+Packages' },
        { mode = 'n', keys = '<Leader>r', desc = '+Replace' },
        { mode = 'n', keys = '<Leader>s', desc = '+Search' },
        { mode = 'n', keys = '<Leader>t', desc = '+Tests' },
        { mode = 'n', keys = '<Leader>u', desc = '+Ui toggles' },
        { mode = 'n', keys = '<Leader>w', desc = '+Treewalker' },

        -- Treewalker navigation with postkeys to stay in submode
        { mode = 'n', keys = '<Leader>w<Down>', postkeys = '<Leader>w', desc = 'Down' },
        { mode = 'n', keys = '<Leader>w<Up>', postkeys = '<Leader>w', desc = 'Up' },
        { mode = 'n', keys = '<Leader>w<Left>', postkeys = '<Leader>w', desc = 'Left' },
        { mode = 'n', keys = '<Leader>w<Right>', postkeys = '<Leader>w', desc = 'Right' },
      },
      {
        { mode = 'n', keys = '<LocalLeader>p', desc = '+Print debug' },
        { mode = 'n', keys = '<LocalLeader>r', desc = '+Replace' },
      },
      -- Enhance this by adding descriptions for <Leader> mapping groups
      miniclue.gen_clues.builtin_completion(),
      miniclue.gen_clues.g(),
      miniclue.gen_clues.marks(),
      miniclue.gen_clues.registers(),
      miniclue.gen_clues.windows(),
      miniclue.gen_clues.z(),
    },
  })
end
return M
