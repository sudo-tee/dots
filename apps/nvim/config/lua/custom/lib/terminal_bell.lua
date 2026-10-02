local function send_bel()
  vim.api.nvim_ui_send('\007')
end

local function should_ring(pane_focused)
  -- Hollow pane focus and terminal-window focus are independent.
  return vim.g.focus_lost == true or pane_focused == false or (pane_focused == nil and vim.g.focus_lost == nil)
end

local function hollow_command(pane_id, command, callback)
  local argv = { 'hollow-cli', '--transport', 'socket' }
  vim.list_extend(argv, command)
  vim.list_extend(argv, { '--id', pane_id })
  vim.system(argv, {}, vim.schedule_wrap(callback))
end

local function pane_focus(result)
  if result.code ~= 0 then
    return nil
  end
  local ok, pane = pcall(vim.json.decode, result.stdout)
  if ok and type(pane) == 'table' and type(pane.is_focused) == 'boolean' then
    return pane.is_focused
  end
end

local function ring_hollow(pane_id)
  hollow_command(pane_id, { 'pane', 'bell' }, function(result)
    if result.code ~= 0 then
      send_bel()
    end
  end)
end

return vim.schedule_wrap(function()
  local pane_id = vim.env.HOLLOW_PANE_ID
  if not pane_id or pane_id == '' or vim.fn.executable('hollow-cli') ~= 1 then
    if should_ring(nil) then
      send_bel()
    end
    return
  end

  hollow_command(pane_id, { 'get', 'pane' }, function(result)
    if should_ring(pane_focus(result)) then
      ring_hollow(pane_id)
    end
  end)
end)
