return { -- Useful plugin to show you pending keybinds.
  'folke/which-key.nvim',
  config = function() -- This is the function that runs, AFTER loading
    require('which-key').setup({
      window = {
        border = 'single',
      },
    })

    -- Document existing key chains
    require('which-key').register({
      ['<leader>c'] = { name = '[C]ode/[C]opilot', _ = 'which_key_ignore' },
      ['<leader>d'] = { name = '[D]ocument', _ = 'which_key_ignore' },
      ['<leader>f'] = { name = '[F]ile', _ = 'which_key_ignore' },
      ['<leader>b'] = { name = '[B]uffer', _ = 'which_key_ignore' },
      ['<leader>j'] = { name = '[J]ump', _ = 'which_key_ignore' },
      ['<leader>g'] = { name = '[G]it', _ = 'which_key_ignore' },
      ['<leader>gf'] = { name = '[F]ile', _ = 'which_key_ignore' },
      ['<leader>gh'] = { name = '[H]unk', _ = 'which_key_ignore' },
      ['<leader>gl'] = { name = 'Git[l]ab', _ = 'which_key_ignore' },
      ['<leader>gd'] = { name = '[D]iff' },
      ['<leader>m'] = { name = '[M]acro', _ = 'which_key_ignore' },
      ['<leader>p'] = { name = '[P]roject', _ = 'which_key_ignore' },
      ['<leader>r'] = { name = '[R]ename/[R]eplace', _ = 'which_key_ignore' },
      ['<leader>s'] = { name = '[S]earch', _ = 'which_key_ignore' },
      ['<leader>t'] = { name = '[T]est', _ = 'which_key_ignore' },
      ['<leader>u'] = { name = '[U]ui', _ = 'which_key_ignore' },
      ['<leader>w'] = { name = '[W]orkspace', _ = 'which_key_ignore' },
    })
  end,
}
