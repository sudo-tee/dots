source <(fzf --zsh)

export FZF_CTRL_T_OPTS="
  --walker-skip .git,node_modules,target
  --preview 'bat -n --color=always {}'
  --bind 'ctrl-y:execute-silent(echo -n {} | pbcopy)+abort'
  --bind 'ctrl-/:change-preview-window(down|hidden|)'
  --header '<C-y> copy | <C-/> toggle preview'"

export FZF_CTRL_R_OPTS="
  --preview 'echo {}' --preview-window up:3:hidden:wrap
  --bind 'ctrl-/:toggle-preview'
  --bind 'ctrl-y:execute-silent(echo -n {2..} | pbcopy)+abort'
  --color header:italic
  --header '<C-y> copy | <C-/> toggle preview'"

export FZF_ALT_C_OPTS="
  --walker-skip .git,node_modules,target
  --preview 'eza --tree --color=always --icons=always {}'
  --bind 'ctrl-y:execute-silent(echo -n {} | pbcopy)+abort'
  --bind 'ctrl-/:change-preview-window(down|hidden|)'
  --header '<C-y> copy | <C-/> toggle preview'"
