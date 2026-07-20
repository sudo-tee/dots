local multiplexer
if vim.env.HOLLOW_PANE_ID then
  multiplexer = require('custom.lib.hollow')
else
  multiplexer = require('custom.lib.wezterm')
end

local function capitalize(s)
  return s:sub(1, 1):upper() .. s:sub(2):lower()
end

local custom_mux = {
  type = 'custom',
  is_in_session = function()
    return true
  end,
  current_pane_id = function()
    return multiplexer.current_pane_id()
  end,
  current_pane_at_edge = function(_)
    return false
  end,
  current_pane_is_zoomed = function()
    return false
  end,
  next_pane = function(direction)
    multiplexer.activate_pane_direction(capitalize(direction))
    return true
  end,
  resize_pane = function(direction, _)
    multiplexer.resize_pane_direction(capitalize(direction))
    return true
  end,
  split_pane = function()
    return false
  end,
}

return {
  'mrjones2014/smart-splits.nvim',
  lazy = true,
  keys = {
    {
      '<leader>ur',
      function()
        require('smart-splits').start_resize_mode()
      end,
      desc = 'Toggle resize window',
    },
    {
      '<C-j>',
      function()
        if vim.bo.filetype == 'snacks_picker_list' then
          vim.cmd('wincmd j')
        else
          require('smart-splits').move_cursor_down()
        end
      end,
      desc = 'Move to split down',
    },
    {
      '<C-k>',
      function()
        if vim.bo.filetype == 'snacks_picker_list' then
          vim.cmd('wincmd k')
        else
          require('smart-splits').move_cursor_up()
        end
      end,
      desc = 'Move to split up',
    },
    {
      '<C-l>',
      function()
        if vim.bo.filetype == 'snacks_picker_list' then
          vim.cmd('wincmd l')
        else
          require('smart-splits').move_cursor_right()
        end
      end,
      desc = 'Move to split right',
    },
    {
      '<C-h>',
      function()
        if vim.bo.filetype == 'snacks_picker_list' then
          vim.cmd('wincmd h')
        else
          require('smart-splits').move_cursor_left()
        end
      end,
      desc = 'Move to split left',
    },
    {
      '<C-Left>',
      function()
        if vim.bo.filetype == 'snacks_picker_list' then
          vim.cmd('wincmd h')
        else
          require('smart-splits').move_cursor_left()
        end
      end,
      desc = 'Move to split left',
    },
    {
      '<C-Down>',
      function()
        if vim.bo.filetype == 'snacks_picker_list' then
          vim.cmd('wincmd j')
        else
          require('smart-splits').move_cursor_down()
        end
      end,
      desc = 'Move to split down',
    },
    {
      '<C-Up>',
      function()
        if vim.bo.filetype == 'snacks_picker_list' then
          vim.cmd('wincmd k')
        else
          require('smart-splits').move_cursor_up()
        end
      end,
      desc = 'Move to split up',
    },
    {
      '<C-Right>',
      function()
        if vim.bo.filetype == 'snacks_picker_list' then
          vim.cmd('wincmd l')
        else
          require('smart-splits').move_cursor_right()
        end
      end,
      desc = 'Move to split right',
    },
    {
      '<C-A-h>',
      function()
        require('smart-splits').resize_left()
      end,
      desc = 'Resize left',
    },
    {
      '<C-A-j>',
      function()
        require('smart-splits').resize_down()
      end,
      desc = 'Resize down',
    },
    {
      '<C-A-k>',
      function()
        require('smart-splits').resize_up()
      end,
      desc = 'Resize up',
    },
    {
      '<C-A-l>',
      function()
        require('smart-splits').resize_right()
      end,
      desc = 'Resize right',
    },
    {
      '<C-A-Left>',
      function()
        require('smart-splits').resize_left()
      end,
      desc = 'Resize left',
    },
    {
      '<C-A-Down>',
      function()
        require('smart-splits').resize_down()
      end,
      desc = 'Resize down',
    },
    {
      '<C-A-Up>',
      function()
        require('smart-splits').resize_up()
      end,
      desc = 'Resize up',
    },
    {
      '<C-A-Right>',
      function()
        require('smart-splits').resize_right()
      end,
      desc = 'Resize right',
    },
  },
  opts = {
    multiplexer_integration = false,
    at_edge = 'stop',
    resize_mode = {
      resize_keys = { '<Left>', '<Down>', '<Up>', '<Right>' },
    },
  },
  init = function()
    vim.g.smart_splits_multiplexer_integration = false
  end,
  config = function(_, opts)
    local mux_api = require('smart-splits.mux')
    mux_api.__mux = custom_mux
    require('smart-splits').setup(opts)
  end,
}
