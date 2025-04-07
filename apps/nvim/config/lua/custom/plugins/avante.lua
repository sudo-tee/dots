return {
  'yetone/avante.nvim',
  event = 'VeryLazy',
  enabled = function()
    return not vim.g.disable_copilot
  end,
  lazy = true,
  version = false, -- set this if you want to always pull the latest change
  ---@module 'avante'
  ---@type avante.Config
  opts = {
    debug = false,
    provider = 'copilot',
    auto_suggestions_provider = nil,
    behaviour = {
      auto_suggestions = false,
      enable_token_counting = false,
    },
    copilot = {
      model = 'o3-mini',
      disable_tools = true,
      -- model = 'claude-3.5-sonnet',
    },
    windows = {
      width = 40,
    },
    file_selector = {
      provider = 'snacks',
    },
  },
  -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
  build = 'make',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'MunifTanjim/nui.nvim',
    --- The below dependencies are optional,
    'echasnovski/mini.nvim',
    'saghen/blink.cmp',
    'zbirenbaum/copilot.lua', -- for providers='copilot'
    {
      -- support for image pasting
      'HakonHarnes/img-clip.nvim',
      event = 'VeryLazy',
      opts = {
        -- recommended settings
        default = {
          -- insert_mode_after_paste = false,
          embed_image_as_base64 = false,
          prompt_for_file_name = false,
          drag_and_drop = {
            insert_mode = false,
          },
          -- required for Windows users
          use_absolute_path = true,
        },
      },
    },
  },
}
