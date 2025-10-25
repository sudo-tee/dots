local keymap_prefix = '<leader>a'
vim.api.nvim_create_user_command('OpencodeReplay', function()
  vim.opt.runtimepath:append('.')
  require('tests.manual.renderer_replay').start({ set_statuscolumn = false })
  vim.schedule(function()
    vim.cmd('ReplayLoad tests/data/perf.json')
  end)
end, {})
return {
  enable = true,
  event = 'VeryLazy',
  -- 'sudo_tee/opencode.nvim',
  dir = '/home/francis/Projects/_nvim/opencode.nvim/',
  ---@module 'opencode'
  ---@type OpencodeConfig
  opts = {
    prefered_picker = 'snacks',
    keymap_prefix = keymap_prefix,
    keymap = {
      editor = {
        ['<leader>aa'] = { 'toggle' },
        ['<leaser>adc'] = {
          function()
            local file = vim.fn.input({ prompt = 'Save capruted event', default = 'tests/data/data.json' })
            if file then
              require('opencode.ui.debug_helper').save_captured_events(file)
            end
          end,
        },
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

    debug = {
      capture_streamed_events = true,
      enabled = true,
    },
  },
  dependencies = {
    'nvim-lua/plenary.nvim',
    'MeanderingProgrammer/render-markdown.nvim',
    'saghen/blink.cmp',
    -- 'hrsh7th/nvim-cmp',
  },
}
