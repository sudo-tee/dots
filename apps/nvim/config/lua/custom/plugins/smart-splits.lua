---@return boolean
local function at_top_edge()
  return vim.fn.winnr() == vim.fn.winnr('k')
end

---@return boolean
local function at_bottom_edge()
  return vim.fn.winnr() == vim.fn.winnr('j')
end

---@return boolean
local function at_left_edge()
  return vim.fn.winnr() == vim.fn.winnr('h')
end

---@return boolean
local function at_right_edge()
  return vim.fn.winnr() == vim.fn.winnr('l')
end

---@param winnr number|nil window ID, defaults to current window
---@return boolean
local function is_full_width(winnr)
  return vim.api.nvim_win_get_width(winnr or 0) == vim.o.columns
end

---@param winnr number|nil window ID, defaults to current window
---@return boolean
local function is_full_height(winnr)
  return vim.api.nvim_win_get_height(winnr or 0) > vim.o.lines - 4 -- bufferline / status line / cmd height
end

return {
  'mrjones2014/smart-splits.nvim',
  event = 'VeryLazy',
  keys = {

    -- resizing splits
    {
      '<leader>wr',
      function()
        require('smart-splits').start_resize_mode()
      end,
      desc = 'Toggle resize window',
    },

    -- move between splits
    {
      '<C-j>',
      function()
        require('smart-splits').move_cursor_down()
      end,
    },
    {
      '<C-k>',
      function()
        require('smart-splits').move_cursor_up()
      end,
    },
    {
      '<C-l>',
      function()
        require('smart-splits').move_cursor_right()
      end,
    },
    {
      '<C-h>',
      function()
        require('smart-splits').move_cursor_left()
      end,
    },
    {
      '<C-Left>',
      function()
        require('smart-splits').move_cursor_left()
      end,
    },
    {
      '<C-Down>',
      function()
        require('smart-splits').move_cursor_down()
      end,
    },
    {
      '<C-Up>',
      function()
        require('smart-splits').move_cursor_up()
      end,
    },
    {
      '<C-Right>',
      function()
        require('smart-splits').move_cursor_right()
      end,
    },
    {
      '<C-A-h>',
      function()
        if at_left_edge() and is_full_width() then
          local wez = require('cunstom.lib.wezterm')
          wez.resize_pane_direction('Left')
        else
          require('smart-splits').resize_left()
        end
      end,
    },
    {
      '<C-A-j>',
      function()
        if at_bottom_edge() and is_full_height() then
          local wez = require('custom.lib.wezterm')
          wez.resize_pane_direction('Down')
        else
          require('smart-splits').resize_down()
        end
      end,
    },
    {
      '<C-A-k>',
      function()
        if at_top_edge() and is_full_height() then
          local wez = require('custom.lib.wezterm')
          wez.resize_pane_direction('Up')
        else
          require('smart-splits').resize_up()
        end
      end,
    },
    {
      '<C-A-l>',
      function()
        if at_right_edge() and is_full_width() then
          local wez = require('custom.lib.wezterm')
          wez.resize_pane_direction('Right')
        else
          require('smart-splits').resize_right()
        end
      end,
    },
    {
      '<C-A-Left>',
      function()
        if at_left_edge() and is_full_width() then
          local wez = require('custom.lib.wezterm')
          wez.resize_pane_direction('Left')
        else
          require('smart-splits').resize_left()
        end
      end,
    },
    {
      '<C-A-Down>',
      function()
        if at_bottom_edge() and is_full_height() then
          local wez = require('custom.lib.wezterm')
          wez.resize_pane_direction('Down')
        else
          require('smart-splits').resize_down()
        end
      end,
    },
    {
      '<C-A-Up>',
      function()
        if at_top_edge() and is_full_height() then
          local wez = require('custom.lib.wezterm')
          wez.resize_pane_direction('Up')
        else
          require('smart-splits').resize_up()
        end
      end,
    },
    {
      '<C-A-Right>',
      function()
        if at_right_edge() and is_full_width() then
          local wez = require('custom.lib.wezterm')
          wez.resize_pane_direction('Right')
        else
          require('smart-splits').resize_right()
        end
      end,
    },
  },
  opts = {
    multiplexer_integration = false,
    ignored_buftypes = { 'Neotree' },
    at_edge = function(mux)
      local utils = require('custom.lib.utils')
      local wez = require('custom.lib.wezterm')

      wez.activate_pane_direction(utils.first_to_upper(mux.direction))
    end,
    resize_mode = {
      resize_keys = { '<Left>', '<Down>', '<Up>', '<Right>' },
    },
  },
}
