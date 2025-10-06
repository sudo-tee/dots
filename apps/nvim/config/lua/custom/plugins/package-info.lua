local function run(start)
  require('custom.lib.task-progress')
    .new({
      get_status = function()
        return require('package-info.ui.generic.loading-status').get()
      end,
      notify_id = 'package-info.nvim',
      title = 'Package Info',
    })
    :start(function()
      start()
    end)
end

return {
  'vuki656/package-info.nvim',
  dependencies = 'MunifTanjim/nui.nvim',
  ft = 'json',
  keys = {
    {
      '<leader>pki',
      function()
        run(function()
          require('package-info').show()
        end)
      end,
      desc = 'Toggle info',
      ft = 'json',
    },
    {
      '<leader>pkI',
      function()
        run(function()
          require('package-info').show({ force = true })
        end)
      end,
      desc = 'Toggle info (force)',
      ft = 'json',
    },
    {
      '<leader>pku',
      function()
        run(function()
          require('package-info').update()
        end)
      end,
      desc = 'Update',
      ft = 'json',
    },
  },
  opts = {
    autostart = false,
    hide_up_to_date = true,
    highlights = {
      outdated = { fg = '#d19a66' },
    },
  },
  config = function(_, opts)
    require('package-info').setup(opts)
  end,
}
