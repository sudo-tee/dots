local keymap_prefix = '<leader>a'
return {
  enable = true,
  event = 'VeryLazy',
  -- 'sudo_tee/opencode.nvim',
  dir = '/home/francis/Projects/_nvim/opencode.nvim/',
  ---@type OpencodeConfig
  opts = {
    prefered_picker = 'snacks',
    default_global_keymaps = false,
    keymap = {
      global = {
        toggle = keymap_prefix .. 'a', -- Open goose. Close if opened
        open_input = keymap_prefix .. 'i', -- Opens and focuses on input window on insert mode
        open_input_new_session = keymap_prefix .. 'I', -- Opens and focuses on input window on insert mode. Creates a new session
        open_output = keymap_prefix .. 'o', -- Opens and focuses on output window
        toggle_focus = keymap_prefix .. 't', -- Toggle focus between goose and last window
        close = 'q', -- Close UI windows
        toggle_fullscreen = keymap_prefix .. 'f', -- Toggle between normal and fullscreen mode
        select_session = keymap_prefix .. 's', -- Select and load a goose session
        goose_mode_chat = keymap_prefix .. 'mc', -- Set goose mode to `chat`. (Tool calling disabled. No editor context besides selections)
        goose_mode_auto = keymap_prefix .. 'ma', -- Set goose mode to `auto`. (Default mode with full agent capabilities)
        configure_provider = keymap_prefix .. 'p', -- Quick provider and model switch from predefined list
        diff_open = keymap_prefix .. 'd', -- Opens a diff tab of a modified file since the last goose prompt
        diff_next = keymap_prefix .. ']', -- Navigate to next file diff
        diff_prev = keymap_prefix .. '[', -- Navigate to previous file diff
        diff_close = keymap_prefix .. 'c', -- Close diff view tab and return to normal editing
        diff_revert_all_last_prompt = keymap_prefix .. 'ra', -- Revert all file changes since the last goose prompt
        diff_revert_this_last_prompt = keymap_prefix .. 'rt',
        diff_restore_snapshot_file = keymap_prefix .. 'rr',
        diff_restore_snapshot_all = keymap_prefix .. 'rR',
        open_configuration_file = keymap_prefix .. 'C',
        swap_position = '<leader>ax', -- Swap Opencode pane left/right
      },
      window = {
        submit_insert = '<C-s>', -- Submit input in input window
        toggle_pane = '<A-p>',
        focus_input = 'i', -- Focus input window
        debug_message = keymap_prefix .. 'D', -- Toggle debug messages
        debug_output = keymap_prefix .. 'O', -- Toggle debug messages
      },
    },
    ui = {
      -- input_position = 'bottom', -- Position of the input window
      display_context_size = true,
      display_cost = true,
    },
    debug = {
      enabled = true,
    },
  },
  dependencies = {
    'nvim-lua/plenary.nvim',
    'MeanderingProgrammer/render-markdown.nvim',
  },
}
