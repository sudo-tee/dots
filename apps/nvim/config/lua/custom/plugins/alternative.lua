return {
  'Goose97/alternative.nvim',
  version = '*', -- Use for stability; omit to use `main` branch for the latest features
  event = 'VeryLazy',
  config = function()
    require('alternative').setup({
      rules = {
        'general.boolean_flip',
        'general.compare_operator_flip',
        'general.number_increment_decrement',

        'javascript.if_condition_flip',
        'javascript.ternary_to_if_else',
        'javascript.function_definition_variants',
        'javascript.arrow_function_implicit_return',

        'typescript.function_definition_variants',

        'lua.if_condition_flip',
        'lua.ternary_to_if_else',
      },
      keymaps = {
        -- Set to false to disable the default keymap for specific actions
        -- alternative_next = false,
        alternative_next = '<M-a>',
        alternative_prev = '<M-x>',
      },
    })
  end,
}
