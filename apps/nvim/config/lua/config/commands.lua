local cmd = vim.api.nvim_create_user_command
cmd("CheckLua", function()
  local plenary = require("plenary")
  local os_env_path = os.getenv("PATH")

  local tests_run = plenary.job:new({
    command = "nvim",
    args = {
      "--headless",
      "--noplugin",
      "-u",
      "tests/minimal.lua",
      "-c",
      [["PlenaryBustedDirectory tests/ {minimal_init = 'tests/minimal.nvim'}"]],
    },
    env = { ["PATH"] = os_env_path },
  })
  tests_run:sync()
  print(vim.inspect(tests_run:result()))
end, {})

cmd("PutShellCmd", function(command)
  local cmd_output = vim.fn.system(command.args)

  -- Trim trailing newline (if any)
  local result = cmd_output:gsub("[\r\n]+$", "")
  -- Write the result to the current buffer
  vim.api.nvim_put({ result }, "c", true, true)
end, { nargs = "*" })

function _G.Term(cmd)
  if os.getenv("TMUX") == nil then
    require("FTerm").run({ cmd })
    return
  end

  local shell = os.getenv("SHELL") or "zsh"
  cmd = cmd or shell
  local tmux_cmd = "tmux popup -d '#{pane_current_path}' -xC -yC -w80% -h75% -E \"tmux attach -t popup || (tmux new-session -s popup -d; tmux send-keys -t popup '"
    .. cmd
    .. "' Enter; tmux attach-session -t popup)\""
  os.execute(tmux_cmd)
end

function _G.TermPopup(cmd)
  if os.getenv("TMUX") == nil then
    require("FTerm").scratch({ cmd = cmd })
    return
  end

  local shell = os.getenv("SHELL") or "zsh"
  cmd = cmd or shell
  local tmux_cmd = "tmux popup -d '#{pane_current_path}' -xC -yC -w80% -h75% \"" .. cmd .. '"'
  os.execute(tmux_cmd)
end

function _G.RunTask(args)
  if args == "e" then
    vim.cmd("e " .. vim.loop.cwd() .. "/Taskfile")
    return
  end

  local command = "./Taskfile " .. args
  TermPopup(command)
end

function _G.RunCommand(args)
  TermPopup(args)
end

cmd("JiraLink", function(ticket)
  require("lib.jira").create_jira_link(ticket.fargs[1])
end, { nargs = "*" })

-- start profiling
cmd("StartProfile", function()
  vim.cmd([[profile start profile.log]])
  vim.cmd([[profile func *]])
  vim.cmd([[profile file *]])
  require("plenary.profile").start("profile-lua.log")
  vim.notify("Profilling ...")
end, {})

cmd("StopProfile", function()
  vim.cmd("profile stop")
  require("plenary.profile").stop()
  vim.notify("End of profilling, opening results")
  vim.cmd("e profile.log")
  vim.cmd("e profile-lua.log")
end, {})

local is_profiling = false
cmd("ToggleProfile", function()
  if is_profiling then
    vim.cmd("StopProfile")
    is_profiling = false
  else
    vim.cmd("StartProfile")
    is_profiling = true
  end
end, {})

-- Edit quickfix
cmd("RemoveQFItem", function()
  local curqfidx = vim.fn.line(".")
  local qfall = vim.fn.getqflist()

  -- Return if there are no items to remove
  if #qfall == 0 then
    return
  end

  -- Remove the item from the quickfix list
  table.remove(qfall, curqfidx)
  vim.fn.setqflist(qfall, "r")

  -- Reopen quickfix window to refresh the list
  vim.cmd("copen")

  -- If not at the end of the list, stay at the same index, otherwise, go one up.
  local new_idx = curqfidx < #qfall and curqfidx or math.max(curqfidx - 1, 1)

  -- Set the cursor position directly in the quickfix window
  local winid = vim.fn.win_getid() -- Get the window ID of the quickfix window
  vim.api.nvim_win_set_cursor(winid, { new_idx, 0 })
end, {})

-- vim.cmd("command! -nargs=1 JiraLink lua _G.create_jira_link(<f-args>)")
vim.cmd("command! -nargs=? TermShell lua _G.Term(<q-args>)")
vim.cmd("command! -nargs=? TermPopup lua _G.TermPopup(<q-args>)")
vim.cmd("command! -nargs=?  T lua _G.RunTask(<q-args>)")
vim.cmd("command! -nargs=?  R lua _G.RunCommand(<q-args>)")
