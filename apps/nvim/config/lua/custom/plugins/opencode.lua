local keymap_prefix = '<leader>a'
vim.api.nvim_create_user_command('OpencodeReplay', function(opts)
  vim.opt.runtimepath:append('.')
  require('tests.manual.renderer_replay').start({ set_statuscolumn = false })
  local file = opts.args ~= '' and opts.args or 'multiple-question-ask-reply-all'
  vim.schedule(function()
    vim.cmd('ReplayLoad tests/data/' .. file .. '.json')
    vim.defer_fn(function()
      vim.cmd('ReplayAll 200')
    end, 1000)
  end)
end, { nargs = '?' })

vim.api.nvim_create_user_command('OpencodeReplaySave', function()
  local file = vim.fn.input({ prompt = 'Save capruted event', default = 'tests/data/data.json' })
  if file then
    require('opencode.ui.debug_helper').save_captured_events(file)
  end
end, {})
return {
  enable = true,
  event = 'VeryLazy',
  -- 'sudo_tee/opencode.nvim',
  dir = '/home/francis/Projects/_nvim/opencode.nvim/',
  ---@type OpencodeConfig
  opts = {
    -- preferred_picker = 'mini.pick',
    -- preferred_picker = 'telescope',
    -- preferred_picker = 'fzf',
    -- preferred_completion = 'vim_complete',
    -- preferred_picker = 'snacks',
    server = {
      url = 'http://127.0.0.1',
      port = 4444,
      -- timeout = 5,
      -- kill_command = nil,
      -- auto_kill = true,
      -- path_map = nil,
    },

    keymap_prefix = keymap_prefix,
    keymap = {
      editor = {
        ['<leader>aa'] = { 'toggle' },
        ['<leader>aus'] = {
          function()
            local file = vim.fn.input({ prompt = 'Save capruted event', default = 'tests/data/data.json' })
            if file then
              require('opencode.ui.debug_helper').save_captured_events(file)
            end
          end,
        },
        ['<leader>aug'] = {
          function()
            require('opencode.api').quick_chat('Write a conventional commit message #diff')
          end,
          desc = 'Generate commit message',
        },
      },
      output_window = {
        ['<tab>'] = false,
      },
      input_window = {
        ['<cr>'] = { 'submit_input_prompt', { 'n' } },
        ['<tab>'] = false,
      },
    },
    output = {
      rendering = {
        markdown_debounce_ms = 250,
        on_data_rendered = nil,
      },
      tools = {
        show_output = true,
      },
    },
    context = {
      diagnostics = {
        warning = false,
        only_closest = true,
      },
    },
    logging = {
      enabled = true,
      level = 'debug',
    },
    debug = {
      capture_streamed_events = true,
      enabled = true,
      show_ids = true,
    },
    quick_chat = {
      default_model = 'github-copilot/gpt-5-mini',
    },
  },
  dependencies = {
    'nvim-lua/plenary.nvim',
    'MeanderingProgrammer/render-markdown.nvim',
    'saghen/blink.cmp',
    -- 'hrsh7th/nvim-cmp',
  },
}
