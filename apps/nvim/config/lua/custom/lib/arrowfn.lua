local M = {}

local CLASS_FIELDS =
  { field_definition = true, public_field_definition = true, private_field_definition = true, method_definition = true }

local MODIFIERS = { modifier = true, accessibility_modifier = true, static = true }

local FUNCTIONS =
  { function_declaration = true, function_expression = true, arrow_function = true, method_definition = true }

local TEMPLATES = {
  regular = {
    class_member = '${modifiers} ${name}${params}${type} ${body}',
    named = 'function ${name}${params}${type} ${body}',
    anonymous = 'function ${params}${type} ${body}',
  },
  arrow = {
    class_member = '${modifiers} ${name} = ${params}${type} => ${body}',
    named = 'const ${name} = ${params}${type} => ${body};',
    anonymous = '${params}${type} => ${body}',
  },
}

local function match_node_type(type_name, node)
  return node and node:type() == type_name and node or nil
end

local function find_child_by_type(node, type_name)
  return vim.iter(node:named_children()):find(function(child)
    return child:type() == type_name
  end)
end

local function is_class_member(node)
  return CLASS_FIELDS[node:type()] or (node:parent() and CLASS_FIELDS[node:parent():type()])
end

local function get_node_text(node)
  return node and vim.treesitter.get_node_text(node, vim.api.nvim_get_current_buf())
end

local function get_return_expression(body_node, is_arrow)
  local return_statement = match_node_type('return_statement', body_node:named_child(0))

  if not is_arrow and return_statement then
    return return_statement and get_node_text(return_statement:named_child(0))
  elseif is_arrow and body_node:type() ~= 'statement_block' then
    return string.format('{ return %s; }', get_node_text(body_node))
  end
end

local function find_parent_declaration(node)
  local parent = node:parent()
  if is_class_member(parent) then
    return parent
  end
  return match_node_type('lexical_declaration', parent:parent()) or node
end

local function format_function(str, parts)
  local text = str:gsub('${([^}]+)}', parts)
  return vim.split(vim.trim(text), '\n', { plain = true })
end

local function get_body(node)
  local body_node = node:named_child(node:named_child_count() - 1)
  return get_return_expression(body_node, node:type() == 'arrow_function') or get_node_text(body_node) or ''
end

local function get_modifiers(node)
  return vim.iter(node:iter_children()):fold('', function(acc, child)
    return MODIFIERS[child:type()] and (acc .. get_node_text(child) .. ' ') or acc
  end)
end

local function get_name(node)
  local property_name = is_class_member(node) and 'property_identifier' or 'identifier'
  local name_node = find_child_by_type(node, property_name) or find_child_by_type(node:parent(), property_name)

  return get_node_text(name_node)
end

local function get_return_type(node)
  return get_node_text(find_child_by_type(node, 'type_annotation')) or ''
end

local function get_parameters(node)
  local params = get_node_text(node:field('parameters')[1] or node:field('parameter')[1]) or ''
  return params:sub(1, 1) == '(' and params or '(' .. params .. ')'
end

local function get_template(node, target_node)
  local template = node:type() == 'arrow_function' and TEMPLATES.regular or TEMPLATES.arrow

  if is_class_member(target_node) then
    return template.class_member
  elseif get_name(node) then
    return template.named
  end
  return template.anonymous
end

local function convert_function(node)
  local target_node = find_parent_declaration(node) or node
  local tpl = get_template(node, target_node)

  local lines = format_function(tpl, {
    modifiers = get_modifiers(target_node or node),
    name = get_name(node),
    params = get_parameters(node),
    type = get_return_type(node),
    body = get_body(node),
  })

  return lines, target_node
end

function M.toggle_function()
  local node = vim.treesitter.get_node()

  while node and not FUNCTIONS[node:type()] do
    node = node:parent()
  end

  if not node then
    return vim.notify('No function found', vim.log.levels.INFO)
  end

  local lines, target_node = convert_function(node)
  local start_row, start_col, end_row, end_col = target_node:range()
  vim.api.nvim_buf_set_text(0, start_row, start_col, end_row, end_col, lines)
end

return M
