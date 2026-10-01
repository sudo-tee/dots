-- Run from repo root: nvim --headless -u NONE -i NONE -l apps/nvim/config/lua/custom/lib/databricks_inline_spec.lua
local module_path = debug.getinfo(1, 'S').source:sub(2):gsub('_spec.lua$', '.lua')
local completion = dofile(module_path)
local checks = 0
local function eq(expected, actual)
  checks = checks + 1
  assert(vim.deep_equal(expected, actual), 'Expected ' .. vim.inspect(expected) .. ', got ' .. vim.inspect(actual))
end

local clean = completion._clean_completion
local function response(insert)
  return vim.json.encode({ insert = insert })
end

local function context(line_prefix, line_suffix, following_lines)
  return {
    line_prefix = line_prefix,
    line_suffix = line_suffix or '',
    following_lines = following_lines or {},
    indent = #line_prefix:match('^%s*'),
  }
end

-- Plain insertion, plus the two ways the model echoes text that is already in the buffer.
eq('ction', clean(response('ction'), context('local fun')))
eq('ction', clean(response('local function'), context('local fun')))
eq('ction', clean(response('function'), context('local fun')))
eq('me', clean(response('me'), context('print(string.upper(na', '))')))
eq('me', clean(response('me))'), context('print(string.upper(na', '))')))
-- Mid-line cursors: the model finishes the line by re-typing what already follows, then runs
-- on into the next statement. Everything from that copy onwards is cut.
eq(
  'rev',
  clean(
    response("rev, { desc = 'Previous ' .. desc })\nend"),
    context("  M.map(mode, '[' .. key, p", ", { desc = 'Previous ' .. desc })")
  )
)
eq(
  'pi.nvim_win_get_config',
  clean(response('pi.nvim_win_get_config(win)\n\nif x then'), context('  local c = vim.a', '(win)'))
)
-- A needle that is not distinctive enough must never truncate a legitimate argument list.
eq('x, 1', clean(response('x, 1'), context('  fn(a', ', opts)')))
-- An answer that is only a copy of what already follows the cursor inserts nothing of value.
eq('', clean(response('))'), context('print(string.upper(na', '))')))
eq('', clean(response(', '), context('  fn(a', ', opts)')))
-- Closers the buffer already has are dropped, but a brace the answer opened itself is kept.
eq('user.name', clean(response('user.name}!`;'), context('  return `Hello ${', '}`;')))
-- Same answer spread over two lines: the closer ends it, the replayed `}` goes with it.
eq('user.name', clean(response('user.name}!`;\n}'), context('  return `Hello ${', '}`;', { '}' })))
eq('a = 1,\n  b = 2,', clean(response('a = 1,\n  b = 2,\n}'), context('local t = {', '}', { '}' })))
eq('a = { b = 1 }', clean(response('a = { b = 1 }'), context('local t = {', '}')))
eq('bufnr, 0, -1', clean(response('bufnr, 0, -1)'), context('  local l = vim.api.nvim_buf_get_lines(', ', false)')))
eq('local x = 1', clean(response('  local x = 1'), context('  ')))
-- Trailing newlines and whitespace-only answers are noise.
eq('h, "r", 438)', clean(response('h, "r", 438)\n'), context('  local fd = uv.fs_open(pat')))
eq('', clean(response('\n'), context('local name = 42')))
eq('', clean(response('   '), context('local ')))
eq('', clean(response('\n\ncount = count + 1'), context("local name = 'ada'")))
eq('\n  next_line = true', clean(response('\n  next_line = true'), context('if x then')))
eq('', clean(response(''), context('local ')))
-- Multi-line completions survive, including ones that start on the next line.
eq(
  '\n\t\treturn nil, err\n\t}',
  clean(response('\n\t\treturn nil, err\n\t}\n'), context('\tif err != nil {', '', { '\tdefer f.Close()', '}' }))
)
eq('\n  ok', clean(response('\r\n  ok'), context('if x then')))
eq('()\n  return true\nend', clean(response('()\n  return true\nend'), context('function M.app')))
-- Trailing lines that merely restate what is already below the cursor are dropped.
eq('()', clean(response('()\n  return true\nend'), context('function M.app', '', { '  return true', 'end' })))
eq('', clean(response('local opts = {}'), context('  ', '', { '  local opts = {}', '  return opts' })))
-- Accepting must never be a no-op: a block that reproduces the lines below the cursor is dropped.
eq('', clean(response('local opts = {}\n  return opts'), context('  ', '', { '  local opts = {}', '  return opts' })))
eq(
  '\n\t\treturn nil, err\n\t}',
  clean(response('\n\t\treturn nil, err\n\t}'), context('\tif err != nil {', '', { '\tdefer f.Close()', '}' }))
)
eq('1', clean(response('1'), context('local x = ', '', { '1 + 2' })))
-- Truncated payloads (the model replaying the file until it runs out of tokens) are salvaged
-- down to their complete lines instead of being thrown away.
eq('()', clean('{"insert":"()\\n  return tr', context('function M.app')))
eq('', clean('{"insert":"ction M.setu', context('local fun')))
eq('', clean('{"insert":"', context('local fun')))
eq('h, "r")', clean('{"insert":"h, \\"r\\")\\n  if not fd th', context('  local fd = uv.fs_open(pat')))
eq('\n\tx := 1', clean('{"insert":"\\n\\tx := 1\\n\\ty :', context('func main() {')))
-- A replayed run of lines that already exist below the cursor is cut off where it starts.
eq(
  'pen_url(url)',
  clean(
    '{"insert":"pen_url(url)\\n  end\\nend\\n\\nlocal function format_link(label, url)"}',
    context('    wezterm.o', '', { '  end', 'end', '', 'local function format_link(label, url)' })
  )
)
-- Suggestions are capped, and a line that dedents out of the cursor's block ends them.
eq(
  '\n    a = 1\n    b = 2\n    c = 3',
  clean(response('\n    a = 1\n    b = 2\n    c = 3\n    d = 4\n    e = 5'), context('  local t = {'))
)
eq('\n    a = 1\n  }', clean(response('\n    a = 1\n  }\n  return t\nend'), context('  local t = {')))
-- Malformed payloads never reach the buffer.
eq('', clean('not JSON', context('local fun')))
eq('', clean(vim.json.encode({ line = 'local function' }), context('local fun')))
eq('', clean(vim.json.encode({ insert = { 'nope' } }), context('local fun')))
eq('ction', clean('```json\n' .. response('ction') .. '\n```', context('local fun')))

vim.o.virtualedit = 'onemore'
local bufnr = vim.api.nvim_get_current_buf()
vim.bo[bufnr].filetype = 'lua'
local function buffer(lines, row, col)
  completion.dismiss()
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
  vim.api.nvim_win_set_cursor(0, { row, col })
end

buffer({ '', 'local fun', '' }, 2, 9)
eq({
  path = '[scratch]',
  language = 'lua',
  before = '\n',
  line_prefix = 'local fun',
  line_suffix = '',
  after = '\n',
  following_lines = { '' },
  indent = 0,
}, completion._get_context(bufnr, 1, 9))
buffer({ 'local name = "Ada"', '  print(string.upper(na))', 'return name' }, 2, 23)
local named = completion._get_context(bufnr, 1, 23)
eq({
  path = '[scratch]',
  language = 'lua',
  before = 'local name = "Ada"\n',
  line_prefix = '  print(string.upper(na',
  line_suffix = '))',
  after = '\nreturn name',
  following_lines = { 'return name' },
  indent = 2,
}, named)
-- The prompt must END at the cursor: code after the cursor is shown first, so continuing the
-- typed line is the only sensible move for the model.
eq(
  'path: [scratch]\nlanguage: lua\n\n<|after|>\n))\nreturn name\n\n<|before|>\nlocal name = "Ada"\n  print(string.upper(na',
  completion._build_prompt(named)
)
local unicode = 'caf' .. string.char(195, 169)
buffer({ unicode .. '()' }, 1, #unicode)
local unicode_context = completion._get_context(bufnr, 0, #unicode)
eq(unicode, unicode_context.line_prefix)
eq('()', unicode_context.line_suffix)
buffer({ string.rep('x', 10000) .. string.rep('y', 10000) }, 1, 10000)
eq(nil, completion._get_context(bufnr, 0, 10000))

-- Sized off the configured budget so tuning context_window cannot silently void these checks.
local window = completion._config().context_window
local euro = string.char(226, 130, 172)
local long_prefix = string.rep(euro, math.floor(window / 12)) .. 'a'
buffer({ long_prefix .. string.rep(euro, math.floor(window / 12)) }, 1, #long_prefix)
local long_context = completion._get_context(bufnr, 0, #long_prefix)
eq(long_prefix, long_context.line_prefix)
eq(string.rep(euro, math.floor(window / 12)), long_context.line_suffix)

-- The byte budget must cut on line boundaries and never inside a UTF-8 codepoint.
local wide, wide_lines = string.rep(euro, 30), {}
for index = 1, 400 do
  wide_lines[index] = wide
end
buffer(wide_lines, 200, 0)
local wide_context = completion._get_context(bufnr, 199, 0)
eq(true, #wide_context.before <= math.floor(window * 0.75))
eq(true, #wide_context.after <= window - math.floor(window * 0.75))
eq(true, #wide_context.before > 0 and #wide_context.after > 0)
for _, line in ipairs(vim.split(wide_context.before .. wide_context.after, '\n', { plain = true })) do
  eq(true, line == '' or line == wide)
end

local requests, notices = {}, {}
vim.env.DATABRICKS_INLINE_TEST_TOKEN = 'synthetic-test-token'
vim.fn.mode = function()
  return 'i'
end
vim.notify = function(message)
  notices[#notices + 1] = message
end
vim.system = function(args, opts, callback)
  local request = { body = vim.json.decode(opts.stdin), callback = callback }
  for index, arg in ipairs(args) do
    if arg == '--header' then
      request.header_file = args[index + 1]:sub(2)
    end
  end
  requests[#requests + 1] = request
  return {
    kill = function()
      request.killed = true
    end,
  }
end
completion.setup({ api_key_env = 'DATABRICKS_INLINE_TEST_TOKEN' })
vim.wait(10, function()
  return false
end)
completion.dismiss()

local function respond(request, content, raw, finish_reason)
  request.callback({
    code = 0,
    stdout = raw or vim.json.encode({
      choices = { { finish_reason = finish_reason or 'stop', message = { content = content } } },
    }),
    stderr = '',
  })
  local flushed = false
  vim.schedule(function()
    flushed = true
  end)
  assert(vim.wait(1000, function()
    return flushed
  end))
  eq(nil, vim.uv.fs_stat(request.header_file))
end

buffer({ 'local fun' }, 1, 9)
completion.request()
local request = requests[#requests]
eq('<|before|>\nlocal fun', request.body.messages[2].content:match('<|before|>\nlocal fun$'))
eq('json_object', request.body.response_format.type)
-- The default model is not a gpt-* endpoint, so no reasoning knobs are sent.
eq(nil, request.body.reasoning_effort)
eq(nil, request.body.max_completion_tokens)
eq(128, request.body.max_tokens)
eq(0.05, request.body.temperature)
-- The prompt must contain the literal lowercase word, or json mode is refused outright.
eq('json', request.body.messages[1].content:match('json'))
respond(request, response('ction'))
eq(true, completion.accept())
eq('local function', vim.api.nvim_get_current_line())
eq({ 1, 14 }, vim.api.nvim_win_get_cursor(0))

buffer({ 'print(string.upper(na))' }, 1, 21)
completion.request()
respond(requests[#requests], response('me'))
eq(true, completion.accept())
eq('print(string.upper(name))', vim.api.nvim_get_current_line())
eq({ 1, 23 }, vim.api.nvim_win_get_cursor(0))

-- Multi-line block completion is the whole point of dropping the single-line contract.
buffer({ 'function M.app' }, 1, 14)
completion.request()
respond(requests[#requests], response('()\n  return true\nend'))
eq(true, completion.accept())
eq({ 'function M.app()', '  return true', 'end' }, vim.api.nvim_buf_get_lines(bufnr, 0, -1, false))
eq({ 3, 3 }, vim.api.nvim_win_get_cursor(0))

buffer({ 'function M.app()', '  return true', 'end' }, 1, 16)
completion.request()
respond(requests[#requests], response('\n  return true\nend'))
eq(false, completion.accept())
eq({ 'function M.app()', '  return true', 'end' }, vim.api.nvim_buf_get_lines(bufnr, 0, -1, false))

-- Accepting word by word, then the rest.
buffer({ 'local fun' }, 1, 9)
completion.request()
respond(requests[#requests], response('ction M.setup(opts)'))
eq(true, completion.accept_word())
eq('local function ', vim.api.nvim_get_current_line())
eq(true, completion.accept())
eq('local function M.setup(opts)', vim.api.nvim_get_current_line())

-- Typing the suggested characters keeps the ghost text instead of dropping it.
buffer({ 'local fun' }, 1, 9)
completion.request()
respond(requests[#requests], response('ction'))
vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { 'local func' })
vim.api.nvim_win_set_cursor(0, { 1, 10 })
eq(true, completion._advance())
eq(true, completion.accept())
eq('local function', vim.api.nvim_get_current_line())

buffer({ 'local fun' }, 1, 9)
completion.request()
respond(requests[#requests], response('ction'))
vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { 'local funx' })
vim.api.nvim_win_set_cursor(0, { 1, 10 })
eq(false, completion._advance())

buffer({ 'local fun' }, 1, 9)
completion.request()
request = requests[#requests]
completion.request()
eq(true, request.killed)
respond(request, response('ction'))
eq(false, completion.accept())
respond(requests[#requests], response('ction'))
eq(true, completion.accept())

buffer({ 'local fun' }, 1, 9)
completion.request()
vim.api.nvim_win_set_cursor(0, { 1, 8 })
respond(requests[#requests], response('ction'))
eq(false, completion.accept())

buffer({ 'local fun' }, 1, 9)
completion.request()
vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { 'local var' })
respond(requests[#requests], response('ction'))
eq(false, completion.accept())

for _, raw in ipairs({ 'not JSON', 'null', 'true', '42' }) do
  buffer({ 'local fun' }, 1, 9)
  completion.request()
  respond(requests[#requests], nil, raw)
  eq('invalid JSON response', notices[#notices])
  eq(false, completion.accept())
end

-- Endpoint errors are surfaced once, not on every keystroke.
local before_notices = #notices
for _ = 1, 3 do
  buffer({ 'local fun' }, 1, 9)
  completion.request()
  respond(requests[#requests], nil, vim.json.encode({ error_code = 'BAD_REQUEST', message = 'unsupported value' }))
end
eq('unsupported value', notices[#notices])
eq(1, #notices - before_notices)

-- Truncation is the normal case now: whole lines are kept, a cut-off line is not.
buffer({ 'local fun' }, 1, 9)
completion.request()
respond(requests[#requests], response('ction'), nil, 'length')
eq(true, completion.accept())
eq('local function', vim.api.nvim_get_current_line())

buffer({ 'function M.app' }, 1, 14)
completion.request()
respond(requests[#requests], '{"insert":"()\\n  return true\\nen', nil, 'length')
eq(true, completion.accept())
eq({ 'function M.app()', '  return true' }, vim.api.nvim_buf_get_lines(bufnr, 0, -1, false))

buffer({ 'local fun' }, 1, 9)
completion.request()
respond(requests[#requests], '{"insert":"ction M.setu', nil, 'length')
eq(false, completion.accept())

-- Endpoints that refuse response_format must not fail forever: drop it and retry once.
buffer({ 'local fun' }, 1, 9)
completion.request()
request = requests[#requests]
eq('json_object', request.body.response_format.type)
respond(
  request,
  nil,
  vim.json.encode({
    error_code = 'BAD_REQUEST',
    message = 'Bad request: "messages" must contain the word "json" in some form',
  })
)
local retried = requests[#requests]
eq(true, retried ~= request)
eq(nil, retried.body.response_format)
respond(retried, response('ction'))
eq(true, completion.accept())
eq('local function', vim.api.nvim_get_current_line())
-- The retry happens once per session, never in a loop.
buffer({ 'local fun' }, 1, 9)
completion.request()
local after_retry = #requests
respond(
  requests[#requests],
  nil,
  vim.json.encode({ error_code = 'BAD_REQUEST', message = 'still complaining about "json"' })
)
eq(after_retry, #requests)

-- gpt-* endpoints take the reasoning branch instead.
completion.setup({ api_key_env = 'DATABRICKS_INLINE_TEST_TOKEN', model = 'databricks-gpt-5-4-mini' })
buffer({ 'local fun' }, 1, 9)
completion.request()
request = requests[#requests]
eq('none', request.body.reasoning_effort)
eq(128, request.body.max_completion_tokens)
eq(nil, request.body.max_tokens)
eq(nil, request.body.temperature)

completion.dismiss()
print(('Databricks inline: %d checks passed'):format(checks))
