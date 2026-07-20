local M = {}

M.commands = {
  OpenWorkspace = 'switch_workspace',
  CreateWorkspace = 'new_workspace',
  Open = 'open',
  Start = 'start',
  ActivatePaneDirection = 'focus_pane',
  ResizePaneDirection = 'resize_pane',
}

-- HTP (Hollow Terminal Protocol) over OSC 1337
-- Frame: ESC ] 1337 ; Hollow ; <json> ESC \
-- See hollow/docs/htp-protocol.md

local function htp_emit(name, payload)
  local id = tostring(vim.fn.pid)
  local payload_json = vim.fn.json_encode(payload or vim.empty_dict())
  local json = string.format('{"kind":"event","id":"%s","name":"%s","payload":%s}', id, name, payload_json)
  local escape_seq = string.format('\027]1337;Hollow;%s\027\\', json)
  M.write_to_term(escape_seq)
end

function M.write_to_term(var)
  local success
  if vim.fn.filewritable('/dev/fd/2') == 1 then
    success = vim.fn.writefile({ var }, '/dev/fd/2', 'b') == 0
  else
    success = vim.fn.chansend(vim.v.stderr, var) > 0
  end
  return success
end

function M.open_url(url)
  pcall(vim.fn.system, 'xdg-open ' .. url)
end

function M.switch_workspace(index)
  htp_emit(M.commands.OpenWorkspace, { index = index })
end

function M.activate_pane_direction(direction)
  htp_emit(M.commands.ActivatePaneDirection, { direction = string.lower(direction) })
end

function M.resize_pane_direction(direction)
  local axis = (direction == 'Left' or direction == 'Right') and 'vertical' or 'horizontal'
  local delta = (direction == 'Left' or direction == 'Up') and -0.05 or 0.05
  htp_emit(M.commands.ResizePaneDirection, { axis = axis, delta = delta })
end

function M.current_pane_id()
  return vim.env.HOLLOW_PANE_ID
end

function M.close_workspace(workspace_id)
  htp_emit('close_workspace', { id = workspace_id })
end

M.kill_workspace = M.close_workspace

return M
