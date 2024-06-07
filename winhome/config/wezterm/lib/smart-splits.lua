---@type Wezterm
---@diagnostic disable-next-line: assign-type-mismatch
local wezterm = require("wezterm")
local function is_vim(pane)
  local vars = pane:get_user_vars()
  local is_nvim = vars["IS_NVIM"] == "true" or vars["WEZTERM_PROG"] == "nvim"
  return is_nvim
end

local direction_keys = {
  Left = "h",
  Down = "j",
  Up = "k",
  Right = "l",
  LeftArrow = "Left",
  DownArrow = "Down",
  UpArrow = "Up",
  RightArrow = "Right",
  -- reverse lookup
  h = "Left",
  j = "Down",
  k = "Up",
  l = "Right",
}

local vim_keys = {
  LeftArrow = "LeftArrow",
  DownArrow = "DownArrow",
  UpArrow = "UpArrow",
  RightArrow = "RightArrow",
}

local M = {}

function M.split_nav(resize_or_move, key)
  return {
    key = key,
    mods = resize_or_move == "resize" and "CTRL|ALT" or "CTRL",
    action = wezterm.action_callback(function(win, pane)
      if is_vim(pane) then
        -- pass the keys through to vim/nvim
        local send_key = key
        if string.len(key) > 1 then
          send_key = vim_keys[key]
        end

        win:perform_action({
          SendKey = { key = send_key, mods = resize_or_move == "resize" and "CTRL|ALT" or "CTRL" },
        }, pane)
      else
        if resize_or_move == "resize" then
          win:perform_action({ AdjustPaneSize = { direction_keys[key], 3 } }, pane)
        else
          win:perform_action({ ActivatePaneDirection = direction_keys[key] }, pane)
        end
      end
    end),
  }
end

function M.setup(config, custom_configs)
  local keys = {
    M.split_nav("move", "h"),
    M.split_nav("move", "j"),
    M.split_nav("move", "k"),
    M.split_nav("move", "l"),
    M.split_nav("move", "LeftArrow"),
    M.split_nav("move", "DownArrow"),
    M.split_nav("move", "UpArrow"),
    M.split_nav("move", "RightArrow"),
    M.split_nav("resize", "h"),
    M.split_nav("resize", "j"),
    M.split_nav("resize", "k"),
    M.split_nav("resize", "l"),
    M.split_nav("resize", "LeftArrow"),
    M.split_nav("resize", "DownArrow"),
    M.split_nav("resize", "UpArrow"),
    M.split_nav("resize", "RightArrow"),
  }

  for _, key in ipairs(keys) do
    table.insert(config.keys, key)
  end
end

return M
