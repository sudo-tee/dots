#!/bin/bash

key="$1"
current_pane="$(tmux display-message -p '#{pane_id}')"
nvim_pane="$(tmux list-panes -F '#{pane_id}:#{pane_current_command}' | grep -E ':(n?vim?x?)$' | cut -d ':' -f 1)"

#echo "c: $current_pane n: $nvim_pane k: $key"

if [ "$current_pane" != "$nvim_pane" ]; then
  tmux send-keys -t "$nvim_pane" "$key"
  tmux select-pane -t "$nvim_pane"
else
  tmux send-keys -t "$current_pane" "$key"
fi
