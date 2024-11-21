return {
  'vuki656/package-info.nvim',
  dependencies = 'MunifTanjim/nui.nvim',
  ft = 'json',
  keys = {
    {
      '<leader>pki',
      function()
        require('package-info').show()
      end,
      desc = 'Toggle info',
      ft = 'json',
    },
    {
      '<leader>pkI',
      function()
        require('package-info').show({ force = true })
      end,
      desc = 'Toggle info (force)',
      ft = 'json',
    },
    {
      '<leader>pku',
      function()
        require('package-info').update()
      end,
      desc = 'Update',
      ft = 'json',
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
