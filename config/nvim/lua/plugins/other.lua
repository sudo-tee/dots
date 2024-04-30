function hasDoubleWord(filename)
  local parts = {}
  for part in string.gmatch(filename, "([^.]+)") do
    table.insert(parts, part)
  end
  -- Remove the last entry
  table.remove(parts)
  -- Check if the last two entries are the same
  return parts[#parts] == parts[#parts - 1]
end

return {
  "rgroli/other.nvim",
  config = function()
    require("other-nvim").setup({
      mappings = {
        {
          context = "implementation",
          pattern = "(.*).spec.ts$",
          target = "%1.ts",
        },
        {
          context = "test",
          pattern = "(.*).ts$",
          target = "%1.spec.ts",
        },
      },
      hooks = {
        -- @param table (filename (string), context (string), exists (boolean))
        -- @return table
        filePickerBeforeShow = function(files)
          for i = #files, 1, -1 do
            local file = files[i]

            if not file.exists and hasDoubleWord(file.filename) then
              table.remove(files, i)
            end
          end

          return files
        end,
      },
      style = {
        -- How the plugin paints its window borders
        -- Allowed values are none, single, double, rounded, solid and shadow
        border = "rounded",

        -- Column seperator for the window
        seperator = "|",

        -- Indicator showing that the file does not yet exist
        newFileIndicator = "(* new *)",

        -- width of the window in percent. e.g. 0.5 is 50%, 1 is 100%
        width = 0.3,

        -- min height in rows.
        -- when more columns are needed this value is extended automatically
        minHeight = 2,
      },
    })
  end,
}
