return {
  'vuki656/package-info.nvim',
  dependencies = 'MunifTanjim/nui.nvim',
  ft = 'json',
  keys = {
    {
      '<leader>pi',
      function()
        require('package-info').show()
      end,
    },
    {
      '<leader>pI',
      function()
        require('package-info').show({ force = true })
      end,
    },
    {
      '<leader>pu',
      function()
        require('package-info').update()
      end,
    },
  },
  opts = {
    autostart = false,
    hide_up_to_date = true,
    colors = {
      outdated = '#d19a66',
    },
  },
  config = function(_, opts)
    require('package-info').setup(opts)

    vim.cmd([[highlight PackageInfoOutdatedVersion guifg=]] .. opts.colors.outdated)
  end,
}
