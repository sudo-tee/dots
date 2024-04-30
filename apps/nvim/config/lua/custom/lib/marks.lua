--- Custom mark API.
--- Inspired by (https://gitlab.com/silvercircle74/nvim):
---   TODO: pluginify (really worth it? This is just so simple)
--- Map of mark information per buffer.
---@type table<integer, table<string, {line: integer, id: integer}>>
local marks = {}
local M = {}

--- Keeps track of the signs I've already created.
---@type table<string, boolean>
local sign_cache = {}

--- The sign and autocommand group name.
local sign_group_name = 'sudo_tee/marks_signs'

--- The autocommand group name.
local sign_group = vim.api.nvim_create_augroup('sudo_tee/marks_signs', {})

---@param mark string
---@return boolean
local function is_lowercase_mark(mark)
  return 97 <= mark:byte() and mark:byte() <= 122
end

---@param mark string
---@return boolean
local function is_uppercase_mark(mark)
  return 65 <= mark:byte() and mark:byte() <= 90
end

---@param mark string
---@return boolean
local function is_letter_mark(mark)
  return is_lowercase_mark(mark) or is_uppercase_mark(mark)
end

---@param mark string
---@param bufnr integer
local function delete_mark(mark, bufnr)
  local buffer_marks = marks[bufnr]
  if not buffer_marks or not buffer_marks[mark] then
    return
  end

  -- Remove the sign.
  vim.fn.sign_unplace(sign_group_name, { buffer = bufnr, id = buffer_marks[mark].id })
  buffer_marks[mark] = nil

  -- Remove the mark.
  vim.cmd('delmarks ' .. mark)
end

local function get_mark_name(mark_data)
  return mark_data.mark:sub(2, 3)
end

---@param mark string
---@param bufnr integer
---@param line? integer
local function register_mark(mark, bufnr, line)
  local buffer_marks = marks[bufnr]
  if not buffer_marks then
    return
  end

  if buffer_marks[mark] then
    -- Mark already exists, remove it first.
    delete_mark(mark, bufnr)
  end

  -- Add the sign to the tracking table.
  local id = mark:byte() * 100
  line = line or vim.api.nvim_win_get_cursor(0)[1]
  buffer_marks[mark] = { line = line, id = id }

  -- Create the sign.
  local sign_name = 'Marks_' .. mark
  if not sign_cache[sign_name] then
    vim.fn.sign_define(sign_name, { text = mark, texthl = 'DiagnosticSignOk' })
    sign_cache[sign_name] = true
  end
  vim.fn.sign_place(id, sign_group_name, sign_name, bufnr, {
    lnum = line,
    priority = 10,
  })
end

function M.setup()
  M.set_keymaps()
  vim.api.nvim_create_autocmd('BufEnter', {
    group = sign_group,
    callback = function(args)
      M.BufWinEnterHandler(args)
    end,
  })
end

function M.add_mark()
  local curbuf = vim.api.nvim_get_current_buf()
  local mark = vim.fn.getcharstr()
  if mark == nil then
    return
  end

  if not is_letter_mark(mark) then
    return
  end
  register_mark(mark, curbuf)
  vim.cmd('normal! m' .. mark)
end

function M.delete_mark()
  local curbuf = vim.api.nvim_get_current_buf()
  local mark = vim.fn.getcharstr()

  if mark == nil then
    return
  end

  if not is_letter_mark(mark) then
    return
  end
  delete_mark(mark, curbuf)
end

function M.delete_all_buffer_marks()
  local curbuf = vim.api.nvim_get_current_buf()
  marks[curbuf] = {}
  vim.fn.sign_unplace(sign_group_name, { buffer = curbuf })
  vim.cmd('delmarks!')
end

-- set key mappings. this is called from keymap.lua globally
function M.set_keymaps()
  local map = vim.keymap.set
  map('n', 'm', M.add_mark, { desc = 'Add [m]ark' })
  map('n', 'dm', M.delete_mark, { desc = '[D]elete [m]ark' })
  map('n', 'dM', M.delete_all_buffer_marks, { desc = '[D]elete all buffer [M]arks' })
  map('n', '<leader>sm', M.telescope_get_user_marks, { desc = '[S]earch user [m]arks' })
end

function M.get_cwd_marks()
  local u = require('custom.lib.utils')

  local all_marks = vim.fn.getmarklist()
  local cwd = vim.fn.getcwd()

  local cwd_marks = {}
  for _, mark in ipairs(all_marks) do
    local filename = vim.fs.normalize(mark.file)
    if filename and u.starts_with(filename, cwd) then
      table.insert(cwd_marks, mark)
    end
  end

  return cwd_marks
end

function M.get_user_marks()
  local user_marks = {}
  local mark_list = vim.fn.getmarklist('%')
  vim.list_extend(mark_list, M.get_cwd_marks())

  for _, mark_data in ipairs(mark_list) do
    local mark = get_mark_name(mark_data)

    if is_letter_mark(mark) then
      table.insert(user_marks, mark_data)
    end
  end
  return user_marks
end

--- handle BufWinEnter events to refresh marks in the signcolumn
--- @param args table: event arguments
function M.BufWinEnterHandler(args)
  local bufnr = args.buf
  -- Only handle normal buffers.
  if vim.bo[bufnr].bt ~= '' then
    return true
  end

  if not marks[bufnr] then
    marks[bufnr] = {}
  end

  -- Remove all marks that were deleted.
  for mark, _ in pairs(marks[bufnr]) do
    if vim.api.nvim_buf_get_mark(bufnr, mark)[1] == 0 then
      delete_mark(mark, bufnr)
    end
  end

  -- Register the letter marks.
  for _, data in ipairs(M.get_user_marks()) do
    local mark = get_mark_name(data)
    local mark_buf, mark_line = unpack(data.pos)
    local cached_mark = marks[bufnr][mark]
    if mark_buf == bufnr and (not cached_mark or mark_line ~= cached_mark.line) then
      register_mark(mark, bufnr, mark_line)
    end
  end
end

function M.telescope_get_user_marks(opts)
  opts = opts or {}
  local conf = require('telescope.config').values
  local bufnr = vim.api.nvim_get_current_buf()
  local bufname = vim.api.nvim_buf_get_name(bufnr)

  local results_data = {}
  local results = {}

  local format_result = function(mark_data)
    local _, lnum, col = unpack(mark_data.pos)

    local text = ''
    if mark_data.file then -- this is a global mark
      text = conf.path_display(nil, mark_data.file)
    else
      text = vim.api.nvim_buf_get_lines(bufnr, lnum - 1, lnum, false)[1]
    end

    return string.format('%s %6d %4d %s', get_mark_name(mark_data), lnum, col - 1, text)
  end

  for _, mark_data in ipairs(M.get_user_marks()) do
    local _, lnum, col = unpack(mark_data.pos)
    table.insert(results, {
      line = format_result(mark_data),
      lnum = lnum,
      col = col,
      filename = vim.fs.normalize(mark_data.file or bufname),
    })

    table.insert(results_data, { mark = get_mark_name(mark_data) })
  end

  require('telescope.pickers')
    .new(opts, {
      prompt_title = 'User Marks',
      finder = require('telescope.finders').new_table({
        results = results,
        entry_maker = require('telescope.make_entry').gen_from_marks(opts),
      }),
      sorter = conf.generic_sorter(opts),
      previewer = conf.grep_previewer(opts),
      attach_mappings = function(buf, map)
        map('i', '<C-x>', function()
          local entry = require('telescope.actions.state').get_selected_entry()
          local mark = results_data[entry.index]

          require('telescope.actions').close(buf)
          delete_mark(mark.mark, bufnr)

          vim.schedule(function()
            M.telescope_get_user_marks(opts)
          end)

          vim.notify('Deleted mark [' .. mark.mark .. ']', vim.log.levels.INFO)
        end, { desc = 'Delete mark' })
        return true
      end,
    })
    :find()
end

return M
