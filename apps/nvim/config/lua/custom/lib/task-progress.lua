local Spinner = require('custom.lib.spinner')

---@class TaskProgress
---@field private notify_id string
---@field private title string
---@field private interval number
---@field private spinner Spinner
---@field private get_status fun(v:any):string
---@field private on_done function|nil
---@field private status_received boolean
---@field private value any
local TaskProgress = {}
TaskProgress.__index = TaskProgress

---Create a new TaskProgress instance
---@param opts? {notify_id?: string, title?: string, interval?: number, get_status: (fun(v:any):string), on_done?: function, spinner?: Spinner}
function TaskProgress.new(opts)
  opts = opts or {}
  local self = setmetatable({
    notify_id = opts.notify_id or ('task-progress' .. math.randomseed(os.time())),
    title = opts.title or 'Task',
    interval = opts.interval or 100,
    spinner = opts.spinner or Spinner.new(),
    value = nil,
    status_received = false,
    get_status = opts.get_status or function(v)
      return ''
    end,
    on_done = opts.on_done,
  }, TaskProgress)
  return self
end

---Notify with a message
---@param message string
---@param conf? table
function TaskProgress:notify(message, conf)
  vim.notify(
    message,
    vim.log.levels.INFO,
    vim.tbl_extend('force', {
      title = self.title,
      id = self.notify_id,
    }, conf or {})
  )
end

---Check status and update progress
function TaskProgress:check_status()
  local status = self.get_status(self.value)

  if status == '' and not self.status_received then
    vim.defer_fn(function()
      self:check_status()
    end, self.interval)
    return
  end

  self.status_received = true

  self:notify(status, {
    timeout = false,
    opts = function(notif)
      notif.icon = self.spinner:next()
    end,
  })

  if status ~= '' then
    vim.defer_fn(function()
      self:check_status()
    end, self.interval)
  else
    vim.defer_fn(function()
      self:notify(self.title .. ' Completed!')
      if self.on_done then
        self.on_done()
      end
    end, 500)
  end
end

---Start progress tracking
---@param on_start function
function TaskProgress:start(on_start)
  self.status_received = false

  self.value = on_start()
  vim.schedule(function()
    self:check_status()
  end)
end

return TaskProgress
