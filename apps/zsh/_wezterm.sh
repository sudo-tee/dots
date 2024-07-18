export WEZTERM_CONFIG_DIR="$HOME/winhome/.config/wezterm/"
export WEZTERM_CONFIG_TMP_DIR="$HOME/winhome/.config/wezterm/tmp"

wezterm_send_user_command() {
  if hash base64 2>/dev/null; then
    if [[ -z "${TMUX}" ]]; then
      printf "\033]1337;SetUserVar=%s=%s\007" "uc" $(echo -n "{\"c\":\"$1\",\"v\":\"$2\"}" | base64) 2>&1
    else
      # <https://github.com/tmux/tmux/wiki/FAQ#what-is-the-passthrough-escape-sequence-and-how-do-i-use-it>
      # Note that you ALSO need to add "set -g allow-passthrough on" to your tmux.conf
      printf "\033Ptmux;\033\033]1337;SetUserVar=%s=%s\007\033\\" "$1" $(echo -n "$2" | base64) 2>&1
    fi
  fi
}

wezterm_write_to_temp_dir() {
  local file_name="msg.$RANDOM"

  mkdir -p "$WEZTERM_CONFIG_TMP_DIR"

  cat "$1" >"$WEZTERM_CONFIG_TMP_DIR/$file_name"

  echo $file_name
}
