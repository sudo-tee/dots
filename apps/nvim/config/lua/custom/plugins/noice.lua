-- Map arrow keys for wildmenu completion
-- It makes the command pallet more usable
vim.api.nvim_set_keymap('c', '<Down>', 'v:lua.get_wildmenu_key("<right>", "<down>")', { expr = true })
vim.api.nvim_set_keymap('c', '<Up>', 'v:lua.get_wildmenu_key("<left>", "<up>")', { expr = true })

function _G.get_wildmenu_key(key_wildmenu, key_regular)
  return vim.fn.wildmenumode() ~= 0 and key_wildmenu or key_regular
end

return {
  'folke/noice.nvim',
  lazy = true,
  event = 'VeryLazy',
  opts = {
    cmdline = {
      format = {
        shell = { pattern = '^:%s*Sh ', icon = '$', lang = 'bash' },
      },
    },
    lsp = {
      override = {
        ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
        ['vim.lsp.util.stylize_markdown'] = true,
        ['cmp.entry.get_documentation'] = true, -- requires hrsh7th/nvim-cmp
      },
    },
    presets = {
      bottom_search = true, -- use a classic bottom cmdline for search
      command_palette = {
        views = {
          cmdline_popup = {
            position = {
              row = 15,
            },
          },
          cmdline_popupmenu = {
            position = {
              row = 18,
            },
          },
        },
      },
      long_message_to_split = true, -- long messages will be sent to a split
      inc_rename = false, -- enables an input dialog for inc-rename.nvim
      lsp_doc_border = true, -- add a border to hover docs and signature help
    },
    routes = {
      {
        filter = {
          event = 'lsp',
          kind = 'progress',
          any = {
            { find = 'Diagnosing' },
            { find = 'Processing full' },
            { find = 'Processing completion' },
          },
        },
        skip = true,
        opts = { skip = true },
      },
      {
        filter = {
          event = 'msg_show',
          any = {
            { find = '%d+L, %d+B' },
            { find = '; after #%d+' },
            { find = '; before #%d+' },
            { find = '^%d+ fewer lines;?' },
            { find = '^%d+ more lines?;?' },
            { find = '^%d+ line less;?' },
            { find = '^%d+ lines yanked$' },
            { find = '^%d+ lines moved$' },
            { find = '^%d+ lines indented$' },
            { find = '^%d+ lines changed$' },
            { find = '^%d+ lines .ed %d+ times?$' },
            { kind = 'emsg', find = 'E490' },
          },
        },
        skip = true,
        opts = { skip = true },
      },
    },
  },
  dependencies = {
    'MunifTanjim/nui.nvim',
  },
}
