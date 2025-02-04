local Cache = {}
Cache.__index = Cache

function Cache.new(ttl)
  return setmetatable({
    ttl = ttl,
    timestamp = 0,
    value = nil,
  }, Cache)
end

function Cache:get(fetch_fn)
  local current_time = os.time()
  if current_time - self.timestamp > self.ttl then
    self.value = fetch_fn()
    self.timestamp = current_time
  end
  return self.value
end

function Cache:clear()
  self.value = nil
  self.timestamp = 0
end

return Cache
