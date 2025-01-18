local function filename_first(item, picker)
  local formatted = Snacks.picker.format.file(item, picker)
  local snacksPickerDirIndex = nil

  for i, v in ipairs(formatted) do
    if v[2] == 'SnacksPickerDir' then
      snacksPickerDirIndex = i
      break
    end
  end

  if snacksPickerDirIndex then
    local item = table.remove(formatted, snacksPickerDirIndex)
    table.insert(formatted, item)
  end
  return formatted
end

return {
  'folke/snacks.nvim',
  dependencies = {
    'stevearc/dressing.nvim',
  },
  lazy = false,
  -- stylua: ignore
  keys = {
    {
      '<leader>up',
      function()
        require('snacks.profiler').toggle()
      end,
    },
    {
      '<leader>uP',
      function()
        require('snacks.profiler').scratch()
      end,
      desc = 'Profiler Scratch Bufer',
    },
    {
      ']]',
      desc = 'Next Reference',
      function()
        Snacks.words.jump(vim.v.count1)
      end,
    },
    {
      '[[',
      desc = 'Prev Reference',
      function()
        Snacks.words.jump(-vim.v.count1)
      end,
    },
    {
      '<leader>un',
      function()
        Snacks.notifier.show_history()
      end,
      desc = 'Notification History',
    },

    { "<leader>z,", function() Snacks.picker.buffers() end, desc = "Buffers" },
    { "<leader>z/", function() Snacks.picker.grep() end, desc = "Grep" },
    { "<leader>z:", function() Snacks.picker.command_history() end, desc = "Command History" },
    { "<leader><space>", function() Snacks.picker.files({layout = "telescope", format=filename_first }) end, desc = "Find Files" },
    -- find
    { "<leader>fb", function() Snacks.picker.buffers() end, desc = "Buffers" },
    { "<leader>fc", function() Snacks.picker.files({ cwd = vim.fn.stdpath("config") }) end, desc = "Find Config File" },
    { "<leader>ff", function() Snacks.picker.files() end, desc = "Find Files" },
    { "<leader>fg", function() Snacks.picker.git_files() end, desc = "Find Git Files" },
    { "<leader>fr", function() Snacks.picker.recent() end, desc = "Recent" },
    -- git
    { "<leader>zgc", function() Snacks.picker.git_log() end, desc = "Git Log" },
    { "<leader>zgs", function() Snacks.picker.git_status() end, desc = "Git Status" },
    -- Grep
    { "<leader>zb", function() Snacks.picker.lines() end, desc = "Buffer Lines" },
    { "<leader>zB", function() Snacks.picker.grep_buffers() end, desc = "Grep Open Buffers" },
    { "<leader>zG", function() Snacks.picker.grep() end, desc = "Grep" },
    { "<leader>zw", function() Snacks.picker.grep_word() end, desc = "Visual selection or word", mode = { "n", "x" } },
    -- search  z
    { '<leader>z"', function() Snacks.picker.registers() end, desc = "Registers" },
    { "<leader>za", function() Snacks.picker.autocmds() end, desc = "Autocmds" },
    { "<leader>zc", function() Snacks.picker.command_history() end, desc = "Command History" },
    { "<leader>zC", function() Snacks.picker.commands() end, desc = "Commands" },
    { "<leader>zd", function() Snacks.picker.diagnostics() end, desc = "Diagnostics" },
    { "<leader>zh", function() Snacks.picker.help() end, desc = "Help Pages" },
    { "<leader>zH", function() Snacks.picker.highlights() end, desc = "Highlights" },
    { "<leader>zj", function() Snacks.picker.jumps() end, desc = "Jumps" },
    { "<leader>zk", function() Snacks.picker.keymaps() end, desc = "Keymaps" },
    { "<leader>zl", function() Snacks.picker.loclist() end, desc = "Location List" },
    { "<leader>zM", function() Snacks.picker.man() end, desc = "Man Pages" },
    { "<leader>zm", function() Snacks.picker.marks() end, desc = "Marks" },
    { "<leader>zR", function() Snacks.picker.resume() end, desc = "Resume" },
    { "<leader>zq", function() Snacks.picker.qflist() end, desc = "Quickfix List" },
    { "<leader>uC", function() Snacks.picker.colorschemes() end, desc = "Colorschemes" },
    { "<leader>qp", function() Snacks.picker.projects() end, desc = "Projects" },
    -- LSP
    { "<leader>zgd", function() Snacks.picker.lsp_definitions() end, desc = "Goto Definition" },
    { "<leader>zgr", function() Snacks.picker.lsp_references() end, nowait = true, desc = "References" },
    { "<leader>zgI", function() Snacks.picker.lsp_implementations() end, desc = "Goto Implementation" },
    { "<leader>zgy", function() Snacks.picker.lsp_type_definitions() end, desc = "Goto T[y]pe Definition" },
    { "<leader>zs", function() Snacks.picker.lsp_symbols() end, desc = "LSP Symbols" },
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
    keys = {},
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
