return { -- Autocompletion
  'hrsh7th/nvim-cmp',
  event = 'InsertEnter',
  dependencies = {
    -- Snippet Engine & its associated nvim-cmp source
    {
      'L3MON4D3/LuaSnip',
      build = 'make install_jsregexp',
    },
    'saadparwaiz1/cmp_luasnip',

    -- Adds other completion capabilities.
    --  nvim-cmp does not ship with all sources by default. They are split
    --  into multiple repos for maintenance purposes.
    'hrsh7th/cmp-nvim-lsp',
    'hrsh7th/cmp-path',
    'hrsh7th/cmp-cmdline',
    'hrsh7th/cmp-buffer',

    -- If you want to add a bunch of pre-configured snippets,
    --    you can use this plugin to help you. It even has snippets
    --    for various frameworks/libraries/etc. but you will have to
    --    set up the ones that are useful for you.
    -- 'rafamadriz/friendly-snippets',
  },
  config = function()
    -- See `:help cmp`
    local cmp = require('cmp')
    local luasnip = require('luasnip')
    local bordered = require('cmp.config.window').bordered

    luasnip.config.setup({})
    cmp.setup({
      snippet = {
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end,
      },
      window = {
        completion = bordered({ border = 'rounded' }),
        documentation = bordered({ border = 'rounded' }),
      },
      completion = { completeopt = 'menu,menuone,noinsert' },

      -- For an understanding of why these mappings were
      -- chosen, you will need to read `:help ins-completion`
      --
      -- No, but seriously. Please read `:help ins-completion`, it is really good!
      mapping = cmp.mapping.preset.insert({
        -- Accept ([y]es) the completion.
        --  This will auto-import if your LSP supports it.
        --  This will expand snippets if the LSP sent a snippet.
        ['<CR>'] = cmp.mapping.confirm({ select = true }),
        -- ['<C-y>'] = cmp.mapping.confirm({ select = true }),

        -- Manually trigger a completion from nvim-cmp.
        --  Generally you don't need this, because nvim-cmp will display
        --  completions whenever it has completion options available.
        ['<C-Space>'] = cmp.mapping.complete({}),

        -- Think of <c-l> as moving to the right of your snippet expansion.
        --  So if you have a snippet that's like:
        --  function $name($args)
        --    $body
        --  end
        --
        -- <c-l> will move you to the right of each of the expansion locations.
        -- <c-h> is similar, except moving you backwards.
        ['<C-l>'] = cmp.mapping(function()
          if luasnip.expand_or_locally_jumpable() then
            luasnip.expand_or_jump()
          end
        end, { 'i', 's' }),
        ['<C-h>'] = cmp.mapping(function()
          if luasnip.locally_jumpable(-1) then
            luasnip.jump(-1)
          end
        end, { 'i', 's' }),
      }),
      sources = {
        { name = 'nvim_lsp' },
        { name = 'luasnip' },
        { name = 'path' },
      },
    })

    cmp.setup.cmdline(':', {
      mapping = cmp.mapping.preset.cmdline({
        ['<C-Down>'] = { c = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }) },
        ['<C-Up>'] = { c = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }) },
      }),
      sources = cmp.config.sources({
        { name = 'path' },
      }, {
        { name = 'cmdline', keyword_length = 3 },
      }),
    })

    cmp.setup.cmdline('/', {
      mapping = cmp.mapping.preset.cmdline({
        ['<C-Down>'] = { c = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }) },
        ['<C-Up>'] = { c = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }) },
      }),
      sources = {
        { name = 'buffer' },
      },
    })
  end,
}
