return {
  'micmine/jumpwire.nvim',
  lazy = true,
  keys = {
    {
      '<M-t>',
      function()
        require('jumpwire').jump('test')
      end,
      desc = 'Jump to alternate test',
    },
    {
      '<M-i>',
      function()
        require('jumpwire').jump('implementation')
      end,
      desc = 'Jump to alternate implementation',
    },
    {
      '<M-T>',
      function()
        vim.cmd(':vs ')
        require('jumpwire').jump('test')
      end,
      desc = 'Split to alternate test',
    },
    {
      '<M-I>',
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
        ['spec.ts'] = {
          implementation = { type = 'fileExtension', data = 'ts' },
        },
        ['test.ts'] = {
          implementation = { type = 'fileExtension', data = 'ts' },
        },
      },
    })
  end,
}
