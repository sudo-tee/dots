return {
  {
    'folke/lazydev.nvim',
    dependencies = {
      { 'Bilal2453/luvit-meta', name = 'luvit-types', lazy = true },
      {
        'DrKJeff16/wezterm-types',
        -- dir = '~/Projects/_nvim/wezterm-types',
      },
    },
    ft = 'lua', -- only load on lua files
    opts = {
      library = {
        -- Library items can be absolute paths
        -- "~/projects/my-awesome-lib",
        -- Or relative, which means they will be resolved as a plugin
        -- "LazyVim",
        -- When relative, you can also provide a path to the library in the plugin dir
        'lazy.nvim',
        { path = 'luvit-types/library', words = { 'vim%.uv' } },
        { path = 'snacks.nvim', words = { 'Snacks' } },
        { path = 'wezterm-types', words = { 'wezterm.' }, mods = { 'wezterm' } },
        { path = vim.env.VIMRUNTIME, words = { 'vim' } },
      },
    },
  },
  { -- optional blink completion source for require statements and module annotations
    'saghen/blink.cmp',
    opts = {
      sources = {
        -- add lazydev to your completion providers
        default = { 'lazydev', 'lsp', 'path', 'snippets', 'buffer' },
        providers = {
          lazydev = {
            name = 'LazyDev',
            module = 'lazydev.integrations.blink',
            -- make lazydev completions top priority (see `:h blink.cmp`)
            score_offset = 100,
          },
        },
      },
    },
  },
  -- { -- optional completion source for require statements and module annotations
  --   'hrsh7th/nvim-cmp',
  --   opts = function(_, opts)
  --     opts.sources = opts.sources or {}
  --     table.insert(opts.sources, {
  --       name = 'lazydev',
  --       group_index = 0, -- set group index to 0 to skip loading LuaLS completions
  --     })
  --   end,
  -- },
  -- { "folke/neodev.nvim", enabled = false }, -- make sure to uninstall or disable neodev.nvim
}
