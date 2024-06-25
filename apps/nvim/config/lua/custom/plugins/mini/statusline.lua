local M = {}

M.setup = function()
  require('mini.statusline').setup({
    use_icons = true,
    set_vim_settings = false,
    content = {
      active = function()
        local search = MiniStatusline.section_searchcount({ trunc_width = 75 })
        local mode, mode_hl = MiniStatusline.section_mode({ trunc_width = 120 })
        local macro = MiniStatusline.macro()
        local git = MiniStatusline.section_git({ trunc_width = 75 })
        local lsp = MiniStatusline.section_lsp({ trunc_width = 75 })
        local diagnostics = MiniStatusline.custom_diagnostics({ trunc_width = 75 })
        local notes = MiniStatusline.section_notes()
        local filename = MiniStatusline.section_filename({ trunc_width = 80 })
        local fileinfo = MiniStatusline.section_fileinfo({ trunc_width = 75 })
        local lazy_updates = MiniStatusline.updates()

        local location = MiniStatusline.section_location({ trunc_width = 75 })
        local copilot_status = MiniStatusline.copilot_status()

        local groups = {
          { hl = 'IncSearch', strings = { search } },
          { hl = mode_hl, strings = { mode } },
          { hl = 'MiniStatuslineDevinfo', strings = { git } },
          { hl = 'MiniStatuslineCustomDiagnosticError', strings = { diagnostics.error } },
          { hl = 'MiniStatuslineCustomDiagnosticWarn', strings = { diagnostics.warn } },
          { hl = 'MiniStatuslineCustomDiagnosticInfo', strings = { diagnostics.info } },
          { hl = 'MiniStatuslineCustomDiagnosticHint', strings = { diagnostics.hint } },
          { hl = 'MiniStatuslineCustomDiagnosticHint', strings = { notes } },
          '%<', -- Mark general truncate point
          { hl = 'MiniStatuslineFilename', strings = { filename } },
          '%=', -- End left alignment
          { hl = 'MiniStatuslineCustomRecordingStatus', strings = { macro } },
          { hl = 'MiniStatuslineCustomUpdatesStatus', strings = { lazy_updates } },
          { hl = 'MiniStatuslineCopilot' .. copilot_status, strings = { '' } },
          { hl = 'MiniStatuslineFileinfo', strings = { lsp, fileinfo } },
          { hl = mode_hl, strings = { location } },
        }

        return MiniStatusline.combine_groups(groups)
      end,
    },
  })

  ---@diagnostic disable-next-line: duplicate-set-field
  MiniStatusline.section_filename = function(args)
    -- In terminal always use plain name
    if vim.bo.buftype == 'terminal' then
      return '%t'
    else
      -- Use relative path
      return '%f%m%r'
    end
  end

  MiniStatusline.copilot_status = function()
    if vim.g.disable_copilot then
      return 'Disabled'
    end

    if package.loaded['copilot'] == nil then
      return 'Offline'
    end

    local status = require('copilot.api').status.data.status
    if status == '' then
      return 'Idle'
    end

    return status
  end

  -- little hackish solution to dislay diagnostics icons and colors

  MiniStatusline.custom_diagnostics = function(opts)
    local diagnostics = MiniStatusline.section_diagnostics(opts)
    local icons = { E = ' ', W = ' ', I = '󰋼 ', H = '󰌵 ' }
    local sections = { error = 'E', warn = 'W', info = 'I', hint = 'H' }

    local result = {}
    for key, symbol in pairs(sections) do
      local count = diagnostics:match(symbol .. '%d+') or ''
      result[key] = count:gsub(symbol, icons[symbol])
    end

    return result
  end

  MiniStatusline.macro = function(_)
    local reg = vim.fn.reg_recording()
    local macro = reg ~= '' and string.format('Recording @%s', reg) or ''

    return macro
  end

  MiniStatusline.updates = function(_)
    if require('lazy.status').has_updates() then
      return require('lazy.status').updates()
    end
  end
  ---@diagnostic disable-next-line: duplicate-set-field
  MiniStatusline.section_location = function(_)
    -- Use virtual column number to allow update when past last column
    return '%2l:%-2v'
  end

  local note_exists_cache = {}

  MiniStatusline.section_notes = function()
    local utils = require('custom.lib.utils')
    local notes_path = vim.g.notes_dir
    local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ':t')

    local filepath = vim.fn.expand('%:p')
    local filename = (vim.fn.pathshorten(filepath, 2) .. '.md'):gsub('%s+', '-'):gsub('/', ':')

    local path = utils.path_join(notes_path, project_name, filename)

    if note_exists_cache[path] ~= nil then
      return note_exists_cache[path]
    end

    if vim.fn.filereadable(path) == 1 then
      note_exists_cache[path] = ''
      return ''
    else
      note_exists_cache[path] = ''
      return ''
    end
  end
end

return M
