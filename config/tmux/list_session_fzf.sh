#!/bin/bash
FZF_DEFAULT_COMMAND="tmux list-sessions -F '#{?session_attached,,#{session_name}}' | sed '/^$/d'";
SESSION_NAME=$(eval $FZF_DEFAULT_COMMAND | fzf --reverse --header "Jump to session" --preview 'tmux capture-pane -pt {}' \
    --bind "alt-r:reload($FZF_DEFAULT_COMMAND)" \
    --bind 'alt-x:execute(tmux kill-session -t {})' \
    --bind "alt-x:+reload($FZF_DEFAULT_COMMAND)")

if [ -n "$SESSION_NAME" ]; then
    tmux switch-client -t $SESSION_NAME
fi

#[[ -n "$SESSION_NAME" ]] && echo $SESSION_NAME 
#[[ -n "$SESSION_NAME" ]] && tmux switch-client -t $SESSION_NAME; sleep 30
