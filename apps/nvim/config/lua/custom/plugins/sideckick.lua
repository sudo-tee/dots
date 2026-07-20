return {
  lazy = false,
  dependencies = {
    'folke/snacks.nvim',
  },
  'folke/sidekick.nvim',
  enabled = true,
  keys = {
    {
      '<tab>',
      function()
        -- if there is a next edit, jump to it, otherwise apply it if any
        if not require('sidekick').nes_jump_or_apply() then
          return '<Tab>' -- fallback to normal tab
        end
      end,
      expr = true,
      desc = 'Goto/Apply Next Edit Suggestion',
    },
  },
  config = function(_, opts)
    require('sidekick').setup(opts)
    if Snacks then
      Snacks.toggle({
        name = 'Copilot NES',
        get = function()
          return vim.g.sidekick_nes == nil or vim.g_sidekick_nes
        end,
        set = function(state)
          vim.g.sidekick_nes = state
        end,
      }):map('<leader>uN')
    end
  end,
}
