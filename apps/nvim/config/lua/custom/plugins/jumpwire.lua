return {
  'micmine/jumpwire.nvim',
  lazy = true,
  keys = {
    {
      '<leader>jt',
      function()
        require('jumpwire').jump('test')
      end,
      desc = 'Jump to alternate test',
    },
    {
      '<leader>ji',
      function()
        require('jumpwire').jump('implementation')
      end,
      desc = 'Jump to alternate implementation',
    },
    {
      '<leader>jT',
      function()
        vim.cmd(':vs ')
        require('jumpwire').jump('test')
      end,
      desc = 'Split to alternate test',
    },
    {
      '<leader>jI',
      function()
        vim.cmd(':vs ')
        require('jumpwire').jump('implementation')
      end,
      desc = 'Split to alternate implementation',
    },
  },
  config = function(opts)
    require('jumpwire').setup({
      language = {
        ['ts'] = {
          test = { type = 'fileExtension', data = 'spec.ts' },
        },
        ['tsx'] = {
          test = { type = 'fileExtension', data = 'spec.tsx' },
        },
        ['spec.ts'] = {
          implementation = { type = 'fileExtension', data = 'ts' },
        },
        ['spec.tsx'] = {
          implementation = { type = 'fileExtension', data = 'tsx' },
        },
        ['test.ts'] = {
          implementation = { type = 'fileExtension', data = 'ts' },
        },
        ['test.tsx'] = {
          implementation = { type = 'fileExtension', data = 'tsx' },
        },
      },
    })
  end,
}
