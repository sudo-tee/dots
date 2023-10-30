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
  print(vim.inspect.inspect(tests_run:result()))
end, {})

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

local neotest_staged_files = function()
  local output = vim.fn.system("git diff --name-only")
  local files = vim.split(output, "\n")
  local file_table = {}

  for _, filename in ipairs(files) do
    if string.sub(filename, -8) == ".test.ts" or string.sub(filename, -8) == ".spec.ts" then
      table.insert(file_table, filename)
    else
      local test_filename = string.gsub(filename, "%.ts$", ".test.ts")
      local spec_filename = string.gsub(filename, "%.ts$", ".spec.ts")
      if vim.fn.filereadable(test_filename) == 1 then
        table.insert(file_table, test_filename)
      elseif vim.fn.filereadable(spec_filename) == 1 then
        table.insert(file_table, spec_filename)
      end
    end
  end

  require("neotest").summary.open()

  for _, filename in ipairs(file_table) do
    local absolute_path = vim.fn.fnamemodify(filename, ":p")
    require("neotest").run.run(absolute_path)
  end
end

vim.keymap.set("n", "<leader>tg", neotest_staged_files, { desc = "Test git changed files" })

function _G.create_jira_link(ticket)
  print(vim.g.jira_host)
  local jira_url = "https://my-jira-url/browse/"

  if vim.g.jira_host then
    jira_url = vim.g.jira_host
  end

  local link = string.format("[%s](%s%s)", ticket, jira_url, ticket)

  local cursor_pos = vim.api.nvim_win_get_cursor(0)

  vim.api.nvim_put({ link }, "c", true, true)
  vim.api.nvim_win_set_cursor(0, cursor_pos)
end

-- start profiling
cmd("StartProfile", function()
  vim.cmd([[profile start profile.log]])
  vim.cmd([[profile func *]])
  vim.cmd([[profile file *")]])
  -- vim.cmd([[set more | verbose function {function_name}]])
  print("Profilling...")
end, {})

cmd("StopProfile", function()
  vim.cmd("profile stop")
  print("End of profilling, opening results")
  vim.cmd("e profile.log")
end, {})

local isProfiling = false
cmd("ToggleProfile", function()
  if isProfiling then
    vim.cmd("StopProfile")
    isProfiling = false
  else
    vim.cmd("StartProfile")
    isProfiling = true
  end
end, {})

vim.cmd("command! -nargs=1 JiraLink lua _G.create_jira_link(<f-args>)")
vim.cmd("command! Ws lua require('lib.wezterm').WeztermSwitchWorkspace()")
vim.cmd("command! -nargs=? TermShell lua _G.Term(<q-args>)")
vim.cmd("command! -nargs=? TermPopup lua _G.TermPopup(<q-args>)")
vim.cmd("command! -nargs=?  T lua _G.RunTask(<q-args>)")
vim.cmd("command! -nargs=?  R lua _G.RunCommand(<q-args>)")
vim.cmd("command! -nargs=? Tl :topleft split | terminal <args>")
