bindkey "^[[3~" delete-char # Delete key: delete char under cursor
bindkey '^[[1;7C' forward-word # Ctrl+Alt+Right: move forward one word
bindkey '^[[1;7D' backward-word # Ctrl+Alt+Left: move backward one word
bindkey '^[f' forward-word # Alt+F: move forward one word
bindkey '^[w' forward-word # Alt+W: same as Alt+F
export XDG_CONFIG_HOME="$HOME/.config"
# Skip wezterm integration inside Hollow (breaks prompt)
if [[ -z "${HOLLOW_WORKSPACE_ID:-}" ]]; then
  source "$HOME/.config/zsh/wezterm.sh"
fi

. "$HOME/.cargo/env"
