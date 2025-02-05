local HALF_LIFE = 30 * 24 * 3600 -- Half-life = 30 days (in seconds)
local LAMBDA = math.log(2) / HALF_LIFE -- λ = ln(2) / half_life
local VISIT_VALUE = 1

Frecency = {}
Frecency.__index = Frecency

local function default_storage_file()
  local path_sep = package.config:sub(1, 1)
  local home = os.getenv("HOME") or os.getenv("USERPROFILE")

  return home .. path_sep .. ".frecency_data.json"
end

local function ensure_storage_file(storage_file)
  local file = io.open(storage_file, "r")
  if not file then
    file = io.open(storage_file, "w")
    if file then
      file:write("{}")
      file:close()
    else
      io.stderr:write("Error creating storage file: " .. storage_file)
    end
  else
    file:close()
  end
end

function Frecency:new(storage_path)
  local instance = setmetatable({}, Frecency)
  instance.items = {}
  instance.storage_file = storage_path or default_storage_file()
  ensure_storage_file(instance.storage_file)
  instance:load()
  return instance
end

function Frecency:visit(item, value)
  local now = os.time()
  local current_score = 0
  if self.items[item] then
    current_score = math.exp(LAMBDA * (self.items[item] - now))
  end
  local new_score = current_score + (value or VISIT_VALUE)
  -- store the "frecency expiration" date instead of raw count/timestamp
  self.items[item] = now + math.log(new_score) / LAMBDA
  self:save()
end

function Frecency:calculate_frecency(item, active_item, current_time)
  current_time = current_time or os.time()
  if not self.items[item] or item == active_item then
    return 0
  end
  return math.exp(LAMBDA * (self.items[item] - current_time))
end

function Frecency:get_ranked_items()
  local current_time = os.time()
  local ranked = {}
  for item, _ in pairs(self.items) do
    local score = self:calculate_frecency(item, nil, current_time)
    table.insert(ranked, { item = item, score = score })
  end
  table.sort(ranked, function(a, b)
    return a.score > b.score
  end)
  return ranked
end

function Frecency:save()
  local file, err = io.open(self.storage_file, "w")
  if not file then
    io.stderr:write("Error opening file for writing: " .. err)
    return
  end
  local encoded = wezterm.json_encode(self.items)
  file:write(encoded)
  file:flush()
  file:close()
end

function Frecency:load()
  local file, err = io.open(self.storage_file, "r")
  if file then
    local content = file:read("*a")
    file:close()
    local data, pos, decode_err = wezterm.json_parse(content)
    if data and type(data) == "table" then
      self.items = data
    else
      io.stderr:write("Error loading storage data: " .. (decode_err or "unknown error"))
    end
  else
    io.stderr:write("Error opening file for reading: " .. err)
  end
end

function Frecency:reset(item)
  self.items[item] = nil
  self:save()
end

return Frecency
