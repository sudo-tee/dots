setopt share_history

# zmodload zsh/zprof
# Created by Zap installer
[ -f "${XDG_DATA_HOME:-$HOME/.local/share}/zap/zap.zsh" ] && source "${XDG_DATA_HOME:-$HOME/.local/share}/zap/zap.zsh"
plug "zsh-users/zsh-autosuggestions"
plug "zap-zsh/supercharge"
plug "zap-zsh/zap-prompt"
plug "zsh-users/zsh-syntax-highlighting"

plug "zsh-users/zsh-history-substring-search"
bindkey '^[[A' history-substring-search-up
bindkey '^[OA' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey '^[OB' history-substring-search-down

# Load and initialise completion system
[ ! "$(find ~/.zcompdump -mtime 1)" ] || compinit
compinit -C

path=(
 ~/.local/bin 
 ~/.local/share/fnm
 ~/.npm-global/bin
 /usr/local/bin
 ~/.cargo/bin
 $path
)

export TSC_WATCHFILE=UseFsEvents
export TSC_NONPOLLING_WATCHER="1"
export NODE_NO_WARNINGS=1
export COLORTERM=truecolor
export DISABLE_AUTO_TITLE='true'
# export TERM='xterm-256color'
export TERM='wezterm'
export EDITOR='nvim'
export VISUAL='nvim'


[[ -f "$HOME/.config/local/zsh/local.sh" ]] && source "$HOME/.config/local/zsh/local.sh"
[[ -f "$HOME/.config/local/zsh/secrets.sh" ]] && source "$HOME/.config/local/zsh/secrets.sh"
[[ -f "$HOME/.config/zsh/aliases.sh" ]] && source "$HOME/.config/zsh/aliases.sh"
[[ -f "$HOME/.config/zsh/ulimit.sh" ]] && source "$HOME/.config/zsh/ulimit.sh"

for file in $HOME/.config/zsh/includes/_*; do
    source "$file"
done


