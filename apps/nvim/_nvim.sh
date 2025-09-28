## set a custom version of node for nvim which reduce memory consumption
## @see https://github.com/yioneko/vtsls/issues/136
nvim() {
  IS_NVIM=true PATH="$HOME/.local/share/node-v22.1.0-linux-x64-pointer-compression/bin:$PATH" ~/.local/share/bob/nvim-bin/nvim "$@"
}
