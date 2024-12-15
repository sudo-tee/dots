return {
  {
    'nvim-neo-tree/neo-tree.nvim',
    lazy = true,
    dependencies = {
      'nvim-lua/plenary.nvim',
      'echasnovski/mini.nvim',
      'MunifTanjim/nui.nvim',
    },
    cmd = 'NeoTree',
    keys = {
      { '<leader>e', '<cmd>Neotree toggle<cr>', desc = 'NeoTree' },
    },
    opts = {
      close_if_last_window = true,
      window = {
        position = 'right',
        mappings = {
          ['<leader>o'] = {
            'toggle_node',
          },
        },
      },
      nesting_rules = {
        ['ts'] = { 'spec.ts', 'spec.tsx', 'stories.tsx', 'stories.mdx' },
        ['tsx'] = { 'spec.ts', 'spec.tsx', 'stories.tsx', 'stories.mdx' },
        ['js'] = { 'd.ts' },
        ['jsx'] = { 'd.ts' },
      },
      filesystem = {
        filtered_items = {
          visible = true, -- when true, they will just be displayed differently than normal items
          hide_dotfiles = false,
          hide_gitignored = false,
          hide_by_name = {
            '.git',
            'node_modules',
            '.vscode',
            '.obsidian',
          },
          hide_by_pattern = { -- uses glob style patterns
            --"*.meta",
            'node_modules/**/*',
          },
        },
        -- bind_to_cwd = true,
        follow_current_file = { enabled = true },
        hijack_netrw_behavior = 'open_default',
        use_libuv_file_watcher = false,
      },
    },
  },
}
