return {
  'akinsho/bufferline.nvim',
  event = 'VeryLazy',
  keys = {
    { '<leader>bp', '<Cmd>BufferLineTogglePin<CR>', desc = 'Toggle [b]uffer [p]in' },
    { '<leader>bP', '<Cmd>BufferLineGroupClose ungrouped<CR>', desc = 'Delete non-[P]inned [b]uffers' },
    { '<leader>bo', '<Cmd>BufferLineCloseOthers<CR>', desc = 'Delete [o]ther [b]uffers' },
    { '<leader>br', '<Cmd>BufferLineCloseRight<CR>', desc = 'Delete [b]uffers to the [r]ight' },
    { '<leader>bl', '<Cmd>BufferLineCloseLeft<CR>', desc = 'Delete [b]uffers to the [l]eft' },
    { '<S-Right>', '<cmd>BufferLineCycleNext<cr>', desc = 'Prev [B]uffer' },
    { '<S-Left>', '<cmd>BufferLineCyclePrev<cr>', desc = 'Next [B]uffer' },
    { '[b', '<cmd>BufferLineCyclePrev<cr>', desc = 'Prev [B]uffer' },
    { ']b', '<cmd>BufferLineCycleNext<cr>', desc = 'Next [B]uffer' },
  },
  opts = function()
    local bufferline = require('bufferline')
    local delete_buffer = function(n)
      require('mini.bufremove').delete(n, false)
    end
    return {
      options = {
        style_preset = bufferline.style_preset.minimal,
        buffer_close_icon = 'x',
        close_command = delete_buffer,
        right_mouse_command = delete_buffer,
        diagnostics = 'nvim_lsp',
        always_show_bufferline = true,
        offsets = {
          {
            filetype = 'neo-tree',
            text = 'Neo-tree',
            highlight = 'Directory',
            text_align = 'left',
          },
        },
      },
    }
  end,
}
