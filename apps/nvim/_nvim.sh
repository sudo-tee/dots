## set a custom version of node for nvim which reduce memory consumption
## @see https://github.com/yioneko/vtsls/issues/136
nvim() {
  IS_NVIM=true PATH="$HOME/.local/share/node-caged:$PATH" ~/.local/share/bob/nvim-bin/nvim "$@"
}
