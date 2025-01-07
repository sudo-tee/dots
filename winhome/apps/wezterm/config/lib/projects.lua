local u = require("lib.utils")
local lume = require("lib.lume")
local wsl_path = wezterm.GLOBAL.wsl_project_path
local project_path = wezterm.GLOBAL.project_path

local M = {}

---@class Project
---@field name string
---@field path string Path of the project relative to wezterm, eg \\wsl$\Ubuntu\home\user\projects\project
---@field cwd string  Working directory of the project, eg /home/user/projects/project

---@return Project[]
function M.get_projects()
  return lume(wezterm.read_dir(wsl_path))
    :filter(function(path)
      local basename = u.basename(path)
      return not basename:match("^_")
    end)
    :map(function(path)
      return { name = u.basename(path), path = path, cwd = project_path .. u.basename(path) }
    end)
    :result()
end

---@return WorkspaceLayout
M.default_layout = function(name, cwd)
  return {
    name = name,
    cwd = cwd,
    command = "nvim",
    title = "editor",
    panes = {
      {
        title = "watch",
        direction = "Bottom",
        size = 0.1,
        command = "t watch",
      },
      {
        title = "shell",
        direction = "Right",
        size = 0.5,
        command = "",
      },
    },
  }
end

---@return WorkspaceLayout
M.get_layout = function(name, path)
  -- hack as reading the \\wsl$ path does not work for links and hidden files
  local sucess, stdout = u.run_child_process({ "cat", path .. "/.wezterm_layout.lua" })
  local layout_file = sucess and load(stdout)

  if type(layout_file) == "function" then
    return layout_file()
  end

  return M.default_layout(name, path)
end

return M
