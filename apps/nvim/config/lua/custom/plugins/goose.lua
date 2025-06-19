local keymap_prefix = '<leader>a'
return {
  enable = true,
  event = 'VeryLazy',
  -- 'azorng/goose.nvim',
  dir = '/home/francis/Projects/_nvim/goose.nvim/',
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
        diff_revert_all = keymap_prefix .. 'ra', -- Revert all file changes since the last goose prompt
        diff_revert_this = keymap_prefix .. 'rt',
      },
      window = {
        submit_insert = '<C-s>', -- Submit input in input window
      },
    },
  },
  config = function(_, opts)
    require('goose').setup(opts)
    local state = require('goose.state')
    local hooks = require('custom.lib.hooks')

    local function at_right_edge()
      return vim.fn.winnr() == vim.fn.winnr('l')
    end

    local function is_goose_focused(expected)
      return function(windows, win)
        local is_focused = win == windows.input_win or win == windows.output_win
        return is_focused == expected
      end
    end

    ---@param name HookName
    ---@param condition function
    ---@param action function
    local function register_goose_hook(name, condition, action)
      hooks.register_hook(name, function()
        local windows = state.windows
        local current_win = vim.api.nvim_get_current_win()
        if not windows or not condition(windows, current_win) then
          return false
        end
        return action(windows, current_win)
      end)
    end

    local function focus_window(target_win)
      vim.api.nvim_set_current_win(target_win)
      return true
    end

    local function is_goose_win(name)
      return function(windows, win)
        return win == windows[name]
      end
    end

    register_goose_hook('move_cursor_right', is_goose_focused(false), function(windows)
      if not at_right_edge() then
        return false
      end
      return focus_window(windows[state.last_focused_goose_window .. '_win'])
    end)

    register_goose_hook('move_cursor_left', is_goose_focused(true), function()
      return focus_window(state.last_code_win_before_goose)
    end)

    register_goose_hook('move_cursor_down', is_goose_win('output_win'), function(windows)
      return focus_window(windows.input_win)
    end)

    register_goose_hook('move_cursor_up', is_goose_win('input_win'), function(windows)
      return focus_window(windows.output_win)
    end)
  end,
  dependencies = {
    'nvim-lua/plenary.nvim',
    'MeanderingProgrammer/render-markdown.nvim',
  },
}
