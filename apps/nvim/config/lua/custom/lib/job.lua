local Job = {}

Job.__index = Job

---Create a new job status handler
---@param command string|string[] Command to execute
---@param opts? {on_status_change: function, on_done: function}
---@return self
function Job.new(command, opts)
  opts = opts or {}
  local self = setmetatable({
    job_id = -1,
    current_status = '',
    is_done = false,
    on_status_change = opts.on_status_change,
    command = command,
  }, Job)

  self.job_id = vim.fn.jobstart(command, {
    on_stdout = function(_, data)
      if data and #data > 1 then
        self:update_status(table.concat(data, '\n'))
      end
    end,
    on_stderr = function(_, data)
      if data and #data > 1 then
        self:update_status(table.concat(data, '\n'))
      end
    end,
    on_exit = function()
      self.current_status = ''
      self.is_done = true
      if opts.on_done then
        opts.on_done()
      end
    end,
    stdout_buffered = false,
    stderr_buffered = false,
  })

  if self.job_id <= 0 then
    error('Failed to start job: ' .. vim.inspect(command))
  end

  return self
end

function Job:update_status(status)
  self.current_status = self.current_status .. '\n' .. status
  if self.on_status_change then
    self.on_status_change(status)
  end
end

function Job:get_status()
  return self.current_status
end

function Job:is_running()
  return not self.is_done
end

function Job:stop()
  if self.job_id > 0 then
    vim.fn.jobstop(self.job_id)
  end
end

function Job:display_progress(title)
  local TaskProgress = require('custom.lib.task-progress')
  local progress = TaskProgress.new({
    title = title or self.command,
    get_status = function()
      return self:get_status()
    end,
    notify_id = 'job-progress' .. self.job_id,
  })
  progress:start(function()
    return self
  end)
end

return Job
