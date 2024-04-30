local M = {}

M.commands = {
  OpenWorkspace = "w:open",
  CreateWorkspace = "w:create",
  Open = "open",
  Start = "start",
  ActivatePaneDirection = "p:activate",
  ResizePaneDirection = "p:resize",
}

local function base64_encode(data)
  local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
  return (
    (data:gsub(".", function(x)
      local r, b = "", x:byte()
      for i = 8, 1, -1 do
        r = r .. (b % 2 ^ i - b % 2 ^ (i - 1) > 0 and "1" or "0")
      end
      return r
    end) .. "0000"):gsub("%d%d%d?%d?%d?%d?", function(x)
      if #x < 6 then
        return ""
      end
      local c = 0
      for i = 1, 6 do
        c = c + (x:sub(i, i) == "1" and 2 ^ (6 - i) or 0)
      end
      return chars:sub(c + 1, c + 1)
    end) .. ({ "", "==", "=" })[#data % 3 + 1]
  )
end

local function basename(file)
  local file_name = file:match("^.+/(.+)$")
  return file_name:sub(0, #file_name - 4)
end

function M.project_files(dir_path)
  local Path = require("plenary.path")
  local scan = require("plenary.scandir")
  dir_path = dir_path or Path:new(os.getenv("HOME"), ".config", "projects").filename
  local files = {}
  for _, entry in ipairs(scan.scan_dir(dir_path)) do
    local file = basename(entry)
    if file ~= "_template" then
      table.insert(files, { file .. ".lua", file })
    end
  end
  return files
end

function M.send_user_var(key, val)
  local encoded_val = base64_encode(val)
  -- equivalent to "\033]1337
  -- see  https://wezfurlong.org/wezterm/recipes/passing-data.html
  local escape_seq = string.format("\027]1337;SetUserVar=%s=%s\a", key, encoded_val)

  M.write_to_term(escape_seq)
end

function M.write_to_term(var)
  local success
  if vim.fn.filewritable("/dev/fd/2") == 1 then
    success = vim.fn.writefile({ var }, "/dev/fd/2", "b") == 0
  else
    success = vim.fn.chansend(vim.v.stderr, var) > 0
  end
  return success
end

function M.send_user_command(command, payload)
  local json_payload = string.format('{"c":"%s","v":"%s"}', command, payload)
  M.send_user_var("uc", json_payload)
end

function M.open_url(url)
  M.send_user_command("open")
end

function M.write_to_wezterm_tmp_dir() end

function M.switch_workspace(workspace)
  M.send_user_command(M.commands.OpenWorkspace, workspace)
end

function M.activate_pane_direction(direction)
  M.send_user_command(M.commands.ActivatePaneDirection, direction)
end

function M.resize_pane_direction(direction)
  M.send_user_command(M.commands.ResizePaneDirection, direction)
end

function M.kill_workspace(workspace)
  local command = string.format(
    'wezterm cli list --format json | jq -r \'.[] | select(.workspace == "%s") | .pane_id\' | xargs -I {pane} wezterm cli kill-pane --pane-id="{pane}"',
    workspace
  )
  vim.fn.system(command)
end

function M.get_workspaces()
  local command = "wezterm cli list --format json | jq -r '.[].workspace' | uniq"
  local output = vim.fn.system(command)

  return vim.split(vim.trim(output), "\n")
end

function M.open_workspace_file(path)
  M.send_user_command(M.commands.CreateWorkspace, path)
end

function M.WeztermSwitchWorkspace()
  local ts = require("lib.telescope")

  ts.simple_picker(M.get_workspaces(), "Select a workspace", function(sel)
    M.switch_workspace(sel.value)
  end, function(_, map, refresh, get_selection)
    -- Create a new empty workspace
    map("i", "<c-n>", function()
      vim.ui.input({ prompt = "Enter Name for new workspace: " }, function(input)
        if input then
          M.switch_workspace(input)
        end
      end)
    end)

    -- Open a new preconfigured workspace
    map("i", "<c-o>", function()
      ts.simple_picker(M.project_files(), "Open a workspace", function(sel)
        M.open_workspace_file(sel.value)
      end)
    end)

    -- Kill the workspace
    map("i", "<c-x>", function()
      local selection = get_selection()
      M.kill_workspace(selection.value)
      refresh(M.get_workspaces())
      vim.notify(string.format("Workspace [%s] Deleted", selection.value))
    end)
  end)
end

return M
