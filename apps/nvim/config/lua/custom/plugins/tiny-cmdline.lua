-- Map arrow keys for wildmenu completion
-- It makes the command pallet more usable
-- vim.api.nvim_set_keymap('c', '<Down>', 'v:lua.get_wildmenu_key("<right>", "<down>")', { expr = true })
-- vim.api.nvim_set_keymap('c', '<Up>', 'v:lua.get_wildmenu_key("<left>", "<up>")', { expr = true })
--
-- function _G.get_wildmenu_key(key_wildmenu, key_regular)
--   return vim.fn.wildmenumode() ~= 0 and key_wildmenu or key_regular
-- end

return {
  enabled = true,
  'rachartier/tiny-cmdline.nvim',
  lazy = false,
  dependencies = { 'saghen/blink.cmp' },
  init = function()
    require('vim._core.ui2').enable({})
    -- required by tiny-cmdline (ui2 renders over cmdheight=0)
    vim.o.cmdheight = 0
  end,
  opts = {
    -- keep native bottom search
    native_types = { '/', '?' },
  },
  -- config runs after plugin on rtp, so direct require (per README sample) resolves
  config = function(_, opts)
    opts.on_reposition = require('tiny-cmdline').adapters.blink
    require('tiny-cmdline').setup(opts)
    vim.api.nvim_set_hl(0, 'TinyCmdlineNormal', { bg = 'NONE' })
    vim.api.nvim_set_hl(0, 'MsgArea', { bg = 'NONE' })
  end,
}
