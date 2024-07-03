return {
  -- 'yujinyuz/gitpad.nvim',
  dir = '~/Projects/_nvim/gitpad.nvim',
  config = function()
    local notes_path = os.getenv('HOME') .. '/Projects/notes/WorkDocs/scratch'
    local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ':t')

    local u = require('custom.lib.utils')
    require('gitpad').setup({
      title = u.first_to_upper(project_name .. ' Notes'),
      border = 'rounded',
      dir = notes_path,
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
