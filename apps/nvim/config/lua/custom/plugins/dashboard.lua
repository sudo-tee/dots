return {
  'nvimdev/dashboard-nvim',
  dependencies = { { 'nvim-tree/nvim-web-devicons' } },
  event = 'VimEnter',
  opts = function()
    local logo = [[
                         ██████████                       
                     ██████████████████                   
                   ██████████████████████                 
                   ██████████████████████                 
                   ██████████████████████                 
                       ██  ██████  ██                     
                     ██████████████████                   
                     ██  ██  ██  ██  ██                   
                   ████  ██  ██  ██  ████                 
                   ██    ██  ██  ██    ██                 
                 ████  ████  ██  ████  ████               
                 ██    ██    ██    ██    ██               
    ]]

    logo = string.rep('\n', 8) .. logo .. '\n\n'

    local opts = {
      theme = 'doom',
      hide = {
        statusline = false,
      },
      config = {
        header = vim.split(logo, '\n'),
        -- stylua: ignore start
        center = {
          { action = "Telescope smart_open",  desc = " Find file",    icon = " ", key = "f" },
          { action = "Telescope oldfiles",    desc = " Recent files", icon = " ", key = "e" },
          { action = "ene | startinsert",     desc = " New file",     icon = " ", key = "n" },
          { action = "Telescope live_grep",   desc = " Find text",    icon = " ", key = "g" },
          { action = "Lazy",                  desc = " Lazy",         icon = "󰒲 ", key = "l" },
          { action = "qa",                    desc = " Quit",         icon = " ", key = "q" },
        },
        -- stylua: ignore end
        footer = function()
          local stats = require('lazy').stats()
          local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
          return { '⚡ Neovim loaded ' .. stats.loaded .. '/' .. stats.count .. ' plugins in ' .. ms .. 'ms' }
        end,
      },
    }

    for _, button in ipairs(opts.config.center) do
      button.desc = button.desc .. string.rep(' ', 43 - #button.desc)
      button.key_format = '  %s'
    end

    -- close Lazy and re-open when the dashboard is ready
    if vim.o.filetype == 'lazy' then
      vim.cmd.close()
      vim.api.nvim_create_autocmd('User', {
        pattern = 'DashboardLoaded',
        callback = function()
          require('lazy').show()
        end,
      })
    end

    return opts
  end,
}
