return {
  'folke/snacks.nvim',
  keys = {
    {
      '<leader>up',
      function()
        require('snacks.profiler').toggle()
      end,
      -- highlights under cursor
    },
    {
      '<leader>uP',
      function()
        require('snacks.profiler').scratch()
      end,
      desc = 'Profiler Scratch Bufer',
    },
  },
  opts = {
    styles = {
      notification = {
        wo = { wrap = true },
      },
    },
    notifier = {
      enabled = true,
    },
  },
}
