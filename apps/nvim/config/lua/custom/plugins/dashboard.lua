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

return {
  'nvimdev/dashboard-nvim',
  dependencies = { { 'juansalvatore/git-dashboard-nvim' } },
  event = 'VimEnter',
  opts = function()
    local git_dashboard = require('git-dashboard-nvim').setup({
      fallback_header = logo,
      use_git_username_as_author = true,
      centered = false,
      top_padding = 10,
      bottom_padding = 2,
      show_contributions_count = true,
      empty_square = '◌',
      filled_squares = { '●', '●', '●', '●', '●', '●', '●' },
      colors = {
        days_and_months_labels = '#8FBCBB',
        empty_square_highlight = '#3B4252',
        filled_square_highlights = { '#88c0d0', '#88c0d0', '#88c0d0', '#88c0d0', '#88c0d0', '#88c0d0', '#88c0d0' },
        -- filled_square_highlights = { '#88c0d0', '#9dcad8', '#b1d5df', '#c5dfe7', '#d8eaef', '#ecf4f7', '#ffffff' },
        branch_highlight = '#88C0D0',
        dashboard_title = '#88C0D0',
      },
    })

    local opts = {
      theme = 'doom',
      hide = {
        statusline = false,
      },
      config = {

        header = git_dashboard,
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
