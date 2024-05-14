local notes_path = os.getenv('HOME') .. '/Projects/notes/WorkDocs/scratch'

local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ':t')
return {
  -- 'yujinyuz/gitpad.nvim',
  dir = '~/Projects/_nvim/gitpad.nvim',
  config = function()
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
        require('gitpad').toggle_gitpad()
      end,
      desc = '',
    },
    {
      '<leader>np',
      function()
        require('gitpad').toggle_gitpad({
          filename = project_name .. '.md',
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
        local filename = vim.fn.expand('%:p') -- or just use vim.fn.bufname()
        if filename == '' then
          vim.notify('empty bufname')
          return
        end
        filename = vim.fn.pathshorten(filename, 2) .. '.md'
        require('gitpad').toggle_gitpad({ filename = filename, title = 'Current file note' })
      end,
      desc = 'current [f]ile',
    },
  },
}
