local project_name
return {
  'sudo-tee/gitpad.nvim',
  -- dir = '~/Projects/_nvim/gitpad.nvim',
  config = function()
    local notes_path = os.getenv('HOME') .. '/Projects/notes/WorkDocs/scratch'
    project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ':t')

    local u = require('custom.lib.utils')

    local ui = vim.api.nvim_list_uis()[1]
    local width = math.floor((ui.width * 0.8) + 0.5)
    local height = math.floor((ui.height * 0.8) + 0.5)
    local col = (ui.width - width) / 2
    local row = (ui.height - height) / 2

    require('gitpad').setup({
      title = u.first_to_upper(project_name .. ' Notes'),
      border = 'rounded',
      dir = notes_path,
      window_type = 'floating',
      floating_win_opts = {
        focusable = true,
        width = width,
        height = height,
        row = row,
        col = col,
      },
      on_attach = function(bufnr)
        vim.api.nvim_buf_set_keymap(bufnr, 'n', 'q', '<Cmd>wq<CR>', { noremap = true, silent = true })
        vim.api.nvim_buf_set_keymap(bufnr, 'n', '<M-q>', '<Cmd>wq<CR>', { noremap = true, silent = true })
      end,
    })
  end,
  keys = {
    {
      '<leader>nv',
      function()
        require('gitpad').toggle_gitpad({})
      end,
      desc = '',
    },
    {
      '<leader>np',
      function()
        project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ':t')
        require('gitpad').toggle_gitpad({
          filename = project_name .. '.md',
          default_text = function(current)
            return current .. '\n\n' .. '%%%\n#' .. project_name .. '\n%%%'
          end,
        })
      end,
      desc = '[p]roject',
    },
    {
      '<leader>nb',
      function()
        require('gitpad').toggle_gitpad_branch({ title = 'Branch Notes' })
      end,
      desc = '[b]ranch',
    },
    -- Daily notes
    {
      '<leader>nd',
      function()
        local date_filename = 'daily-' .. os.date('%Y-%m-%d.md')
        require('gitpad').toggle_gitpad({ filename = date_filename })
      end,
      desc = '[d]aily',
    },
    -- Per file notes
    {
      '<leader>nf',
      function()
        local u = require('custom.lib.utils')
        local filename = vim.fn.expand('%:t')
        local path = vim.fn.expand('%:p:h')
        if filename == '' then
          vim.notify('empty bufname')
          return
        end
        local note_filename = string.format('%s-%s.md', filename, u.string_hash(path))
        require('gitpad').toggle_gitpad({ filename = note_filename, title = 'Current file note' })
      end,
      desc = 'current [f]ile',
    },
  },
}
