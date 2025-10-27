return {
  priority = 1000,
  'folke/snacks.nvim',
  lazy = false,
  -- stylua: ignore
  keys = {
    { '<leader>up',  function() Snacks.profiler.toggle() end,         desc = 'Toggle Profiler' },
    { '<leader>uP',  function() Snacks.profiler.scratch() end,        desc = 'Profiler Scratch Buffer' },
    { ']]',          function() Snacks.words.jump(vim.v.count1) end,  desc = 'Next Reference' },
    { '[[',          function() Snacks.words.jump(-vim.v.count1) end, desc = 'Prev Reference' },
    { '<leader>un',  function() Snacks.notifier.show_history() end,   desc = 'Notification History' },
  },
  ---@type snacks.Config
  opts = {
    bigfile = { enabled = true },
    quickfile = { enabled = true },
    styles = {
      notification = {
        wo = { wrap = true },
      },
    },
    notifier = {
      enabled = true,
    },
    words = {
      enabled = true,
    },
    debug = {
      enabled = true,
    },
    terminal = {
      enabled = false,
    },
    picker = {
      enabled = true,
    },
    statuscolumn = {
      enabled = true,
    },
    input = {
      enabled = true,
    },
    profiler = {
      enabled = true,
      globals = { 'vim' },
    },
    gitbrowse = {
      enabled = true,
      url_patterns = {
        ['gitlab[-%w_]*%.%a+'] = {
          branch = '/-/tree/{branch}',
          file = '/-/blob/{branch}/{file}#L{line_start}-L{line_end}',
          permalink = '/-/blob/{commit}/{file}#L{line_start}-L{line_end}',
          commit = '/-/commit/{commit}',
        },
      },
    },
  },
  init = function()
    vim.api.nvim_create_autocmd('User', {
      pattern = 'VeryLazy',
      callback = function()
        -- Setup some globals for debugging (lazy-loaded)
        _G.dd = function(...)
          Snacks.debug.inspect(...)
        end
        _G.bt = function()
          Snacks.debug.backtrace()
        end
        vim.print = _G.dd -- Override print to use snacks for `:=` command

        -- Create some toggle mappings
        Snacks.toggle.option('spell', { name = 'Spelling' }):map('<leader>us')
        Snacks.toggle.option('wrap', { name = 'Wrap' }):map('<leader>uw')
        Snacks.toggle.option('relativenumber', { name = 'Relative Number' }):map('<leader>uL')
        Snacks.toggle.diagnostics():map('<leader>ud')
        Snacks.toggle.line_number():map('<leader>ul')
        Snacks.toggle
          .option('conceallevel', { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 })
          :map('<leader>uc')
        Snacks.toggle.treesitter():map('<leader>uT')
        Snacks.toggle.inlay_hints():map('<leader>uh')
      end,
    })
  end,
}
