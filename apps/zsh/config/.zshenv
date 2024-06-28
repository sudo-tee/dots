bindkey "^[[3~" delete-char
bindkey '^[[1;7C' forward-word
bindkey '^[[1;7D' backward-word
export XDG_CONFIG_HOME="$HOME/.config"
source "$HOME/.config/zsh/wezterm.sh"

. "$HOME/.cargo/env"
