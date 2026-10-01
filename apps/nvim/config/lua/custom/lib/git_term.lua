-- Run git commands in a single floating terminal. When git needs an editor (commit message,
-- rebase todo, ...), the file opens in the same float and the terminal comes back once the
-- buffer is closed, so hooks output, message editing and the final result share one window.
--
-- In the editor: `:wq` / `:x` continue, `:q!` (discarding changes) aborts the git command.
-- After the command exits the float is left in normal mode: `q`, `<Esc>` or `<CR>` close it.

local M = {}

local editor_script = [[
file="$(cd "$(dirname "$1")" && pwd)/$(basename "$1")"
lock="$(mktemp)"
if ! nvim --server "$NVIM" --remote-expr "v:lua.GitTermEdit('$file', '$lock')" >/dev/null; then
  rm -f "$lock"
  exit 1
fi
while [ -e "$lock" ]; do sleep 0.1; done
if [ -e "$lock.abort" ]; then
  rm -f "$lock.abort"
  exit 1
fi
]]

---@class GitTermState
---@field buf? integer terminal buffer
---@field win? integer float window
---@field job? integer
---@field cmd? string
---@field exit_code? integer
local state = {}

local function editor_path()
  local path = vim.fn.stdpath('cache') .. '/git-term-editor.sh'
  if vim.fn.filereadable(path) == 0 or table.concat(vim.fn.readfile(path), '\n') ~= vim.trim(editor_script) then
    vim.fn.writefile(vim.split(vim.trim(editor_script), '\n'), path)
  end
  return path
end

local function running()
  return state.job ~= nil and vim.fn.jobwait({ state.job }, 0)[1] == -1
end

local function title()
  local status = ''
  if state.exit_code == 0 then
    status = ' ✓'
  elseif state.exit_code then
    status = ' ✗ ' .. state.exit_code
  end
  return ' ' .. (state.cmd or '') .. status .. ' '
end

local function win_config()
  local width = math.floor(vim.o.columns * 0.8)
  local height = math.floor(vim.o.lines * 0.8)
  return {
    relative = 'editor',
    width = width,
    height = height,
    row = math.floor((vim.o.lines - height) / 2) - 1,
    col = math.floor((vim.o.columns - width) / 2),
    border = 'rounded',
    style = 'minimal',
    title = title(),
    title_pos = 'center',
  }
end

local function win_valid()
  return state.win ~= nil and vim.api.nvim_win_is_valid(state.win)
end

local function update_title(text)
  if win_valid() then
    vim.api.nvim_win_set_config(state.win, { title = text or title(), title_pos = 'center' })
  end
end

--- Show `buf` in the float, creating the float if needed, and focus it.
local function show(buf)
  if win_valid() then
    vim.api.nvim_win_set_buf(state.win, buf)
    vim.api.nvim_set_current_win(state.win)
  else
    state.win = vim.api.nvim_open_win(buf, true, win_config())
  end
end

local function focus_terminal()
  if not (state.buf and vim.api.nvim_buf_is_valid(state.buf)) then
    return
  end
  show(state.buf)
  update_title()
  if running() then
    vim.cmd.startinsert()
  else
    vim.cmd.stopinsert()
  end
end

function M.close()
  if win_valid() then
    vim.api.nvim_win_close(state.win, true)
  end
  state.win = nil
  if not running() and state.buf and vim.api.nvim_buf_is_valid(state.buf) then
    vim.api.nvim_buf_delete(state.buf, { force = true })
    state.buf = nil
  end
end

--- Called by the editor script through `--remote-expr`.
---@param file string
---@param lock string file the editor script waits on; removed once the buffer is closed
function M.edit(file, lock)
  vim.schedule(function()
    if state.buf and vim.api.nvim_buf_is_valid(state.buf) then
      show(state.buf)
    end
    vim.cmd.edit(vim.fn.fnameescape(file))

    local buf = vim.api.nvim_get_current_buf()
    vim.bo[buf].bufhidden = 'wipe'
    vim.bo[buf].buflisted = false
    update_title(' ' .. vim.fn.fnamemodify(file, ':t') .. ' — :wq continue · :q! abort ')

    if vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1] == '' then
      vim.api.nvim_win_set_cursor(0, { 1, 0 })
      vim.cmd.startinsert()
    else
      vim.cmd.stopinsert()
    end

    local aborted = false
    vim.api.nvim_create_autocmd('BufUnload', {
      buffer = buf,
      once = true,
      callback = function()
        aborted = vim.bo[buf].modified
      end,
    })
    vim.api.nvim_create_autocmd('BufWipeout', {
      buffer = buf,
      once = true,
      callback = function()
        if aborted then
          vim.fn.writefile({}, lock .. '.abort')
        end
        os.remove(lock)
        vim.schedule(focus_terminal)
      end,
    })
  end)
  return ''
end

_G.GitTermEdit = M.edit

---@param cmd string shell command
function M.run(cmd)
  if running() then
    vim.notify('git command already running: ' .. state.cmd, vim.log.levels.WARN)
    focus_terminal()
    return
  end
  M.close()

  local editor = 'sh ' .. vim.fn.shellescape(editor_path())
  state = { cmd = cmd, buf = vim.api.nvim_create_buf(false, true) }
  local buf = state.buf
  vim.bo[buf].bufhidden = 'hide'
  show(buf)

  state.job = vim.fn.jobstart({ 'zsh', '-c', 'source ~/.zshrc && ' .. cmd }, {
    term = true,
    env = { GIT_EDITOR = editor, GIT_SEQUENCE_EDITOR = editor },
    on_exit = function(_, code)
      vim.schedule(function()
        if state.buf ~= buf then
          return
        end
        state.exit_code = code
        if win_valid() and vim.api.nvim_win_get_buf(state.win) == buf then
          update_title()
          if vim.api.nvim_get_current_win() == state.win then
            vim.cmd.stopinsert()
          end
        elseif code ~= 0 then
          focus_terminal()
        else
          vim.notify(cmd .. ' ✓')
          M.close()
        end
      end)
    end,
  })

  for _, lhs in ipairs({ 'q', '<Esc>', '<CR>' }) do
    vim.keymap.set('n', lhs, function()
      if running() then
        -- Hide while running; the float comes back if the command fails.
        vim.api.nvim_win_close(state.win, true)
        state.win = nil
      else
        M.close()
      end
    end, { buffer = buf, nowait = true, desc = 'Close git terminal' })
  end

  vim.cmd.startinsert()
end

--- Re-open the float of the last/current git command.
function M.toggle()
  if win_valid() then
    vim.api.nvim_win_close(state.win, true)
    state.win = nil
  else
    focus_terminal()
  end
end

return M
