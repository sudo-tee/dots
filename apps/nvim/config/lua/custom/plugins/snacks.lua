vim.api.nvim_create_user_command(
  'SnacksProfilerExport',
  function (opts)
    local args = vim.split(opts.args or '', '%s+', { trimempty = true })
    local fmt = args[1] or 'json'
    local outpath = args[2] or vim.fn.expand('~') .. '/snacks-profile.' .. (fmt == 'flamegraph' and 'txt' or 'json')

    local profiler = require('snacks.profiler')
    local tracer = profiler.tracer

    if #profiler.core.events == 0 then
      vim.notify(
        '[SnacksProfilerExport] No profiler data found.\n' .. 'Toggle a profiling session first.', vim.log.levels.WARN
      )
      return
    end

    tracer.load()

    if #tracer.root == 0 then
      vim.notify('[SnacksProfilerExport] No completed profiler traces found yet.', vim.log.levels.WARN)
      return
    end

    local content

    if fmt == 'json' then
      local all = {}
      tracer.walk(function (node)
        all[#all + 1] = { name = node.name, time = node.time or 0, count = 1, depth = node.depth or 0 }
      end)

      table.sort(all, function (a, b)
        return (a.time or 0) > (b.time or 0)
      end)

      local lines = { '[' }
      for i, node in ipairs(all) do
        local comma = i < #all and ',' or ''
        lines[#lines + 1] = string.format(
          '  {"name":%q,"time_ms":%.3f,"time_s":%.6f,"count":%d,"depth":%d}%s', tostring(node.name or '?'),
          (node.time or 0) / 1e6, (node.time or 0) / 1e9, (node.count or 1), (node.depth or 0), comma
        )
      end
      lines[#lines + 1] = ']'
      content = table.concat(lines, '\n')
    elseif fmt == 'flamegraph' then
      local lines = {}
      local stack = {}

      tracer.walk(function (node)
        stack[#stack + 1] = tostring(node.name or '?'):gsub(';', '|')
      end,
        function (node)
          if (node.time or 0) > 0 then
            local us = math.max(1, math.floor((node.time or 0) / 1e3))
            lines[#lines + 1] = table.concat(stack, ';') .. ' ' .. us
          end
          stack[#stack] = nil
        end)

      if #lines == 0 then
        vim.notify('[SnacksProfilerExport] flamegraph: no data after walk.', vim.log.levels.WARN)
        return
      end
      content = table.concat(lines, '\n')
    else
      vim.notify('[SnacksProfilerExport] Unknown format: ' .. fmt, vim.log.levels.ERROR)
      return
    end

    -- ── Write ──────────────────────────────────────────────────────────────────
    local f = io.open(outpath, 'w')
    if not f then
      vim.notify('[SnacksProfilerExport] Cannot write: ' .. outpath, vim.log.levels.ERROR)
      return
    end
    f:write(content)
    f:close()
    vim.notify(string.format('[SnacksProfilerExport] %s → %s', fmt, outpath), vim.log.levels.INFO)
  end,
  {
    nargs = '*',
    desc = 'Export Snacks profiler data (json|flamegraph) [path]',
    complete = function (_, line)
      local parts = vim.split(line, '%s+', { trimempty = true })
      if #parts <= 1 or parts[2] == nil then
        return { 'json', 'flamegraph' }
      end
      return vim.fn.getcompletion(parts[#parts], 'file')
    end
  }
)
return {
  priority = 1000,
  'folke/snacks.nvim',
  lazy = false,
  -- stylua: ignore
  keys = {
    {
      '<leader>up',
      function ()
        Snacks.profiler.toggle()
      end,
      desc = 'Toggle Profiler'
    },
    {
      '<leader>uP',
      function ()
        Snacks.profiler.scratch()
      end,
      desc = 'Profiler Scratch Buffer'
    },
    {
      ']]',
      function ()
        Snacks.words.jump(vim.v.count1)
      end,
      desc = 'Next Reference'
    },
    {
      '[[',
      function ()
        Snacks.words.jump(-vim.v.count1)
      end,
      desc = 'Prev Reference'
    },
    {
      '<leader>un',
      function ()
        Snacks.notifier.show_history()
      end,
      desc = 'Notification History'
    }
  },
  ---@type snacks.Config
  opts = {
    bigfile = { enabled = true },
    quickfile = { enabled = true },
    styles = {
      notification = {
        wo = { wrap = true }
      }
    },
    notifier = {
      enabled = true
    },
    words = {
      enabled = true
    },
    debug = {
      enabled = true
    },
    terminal = {
      enabled = false
    },
    picker = {
      enabled = true
    },
    statuscolumn = {
      enabled = true
    },
    input = {
      enabled = true
    },
    profiler = {
      enabled = true,
      globals = { 'vim' }
    },
    gitbrowse = {
      enabled = true,
      url_patterns = {
        ['gitlab[-%w_]*%.%a+'] = {
          branch = '/-/tree/{branch}',
          file = '/-/blob/{branch}/{file}#L{line_start}-L{line_end}',
          permalink = '/-/blob/{commit}/{file}#L{line_start}-L{line_end}',
          commit = '/-/commit/{commit}'
        }
      }
    }
  },
  init = function ()
    vim.api.nvim_create_autocmd('User', {
      pattern = 'VeryLazy',
      callback = function ()
        -- Setup some globals for debugging (lazy-loaded)
        _G.dd = function (...)
          Snacks.debug.inspect(...)
        end
        _G.bt = function ()
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
      end
    })
  end
}
