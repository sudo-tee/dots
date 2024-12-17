return { -- Highlight, edit, and navigate code
  'nvim-treesitter/nvim-treesitter',
  lazy = true,
  event = 'LazyFile',

  dependencies = { 'nvim-treesitter/nvim-treesitter-textobjects' },
  build = ':TSUpdate',
  config = function()
    -- [[ Configure Treesitter ]] See `:help nvim-treesitter`

    ---@diagnostic disable-next-line: missing-fields
    require('nvim-treesitter.configs').setup({
      ensure_installed = {
        'bash',
        'c',
        'html',
        'lua',
        'markdown',
        'vim',
        'vimdoc',
        'javascript',
        'typescript',
        'tsx',
        'ron',
        'rust',
        'toml',
        'diff',
      },
      -- Autoinstall languages that are not installed
      auto_install = true,
      highlight = { enable = true },
      indent = { enable = true },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = '<C-space>',
          node_incremental = '<C-space>',
          scope_incremental = false,
          node_decremental = '<bs>',
        },
      },
      textobjects = {
        select = {
          enable = true,
          lookahead = true,
          keymaps = {
            ['af'] = '@function.outer',
            ['if'] = '@function.inner',
            ['ac'] = '@class.outer',
            ['ic'] = '@class.inner',
            ['a,'] = '@parameter.outer',
            ['i,'] = '@parameter.inner',
          },
        },
        move = {
          enable = true,
          set_jumps = true,
          goto_next_start = {
            [']f'] = '@function.outer',
            [']c'] = '@class.outer',
            ['],'] = '@parameter.inner',
          },
          goto_next_end = {
            [']F'] = '@function.outer',
            [']C'] = '@class.outer',
          },
          goto_previous_start = {
            ['[f'] = '@function.outer',
            ['[c'] = '@class.outer',
            ['[,'] = '@parameter.inner',
          },
          goto_previous_end = {
            ['[F'] = '@function.outer',
            ['[C'] = '@class.outer',
          },
        },
        swap = {
          enable = true,
          swap_next = { ['>,'] = '@parameter.inner' },
          swap_previous = { ['<,'] = '@parameter.inner' },
        },
      },
    })

    -- There are additional nvim-treesitter modules that you can use to interact
    -- with nvim-treesitter. You should go explore a few and see what interests you:
    --
    --    - Incremental selection: Included, see :help nvim-treesitter-incremental-selection-mod
    --    - Show your current context: https://github.com/nvim-treesitter/nvim-treesitter-context
    --    - Treesitter + textobjects: https://github.com/nvim-treesitter/nvim-treesitter-textobjects
  end,
}
