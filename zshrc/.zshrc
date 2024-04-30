# zmodload zsh/zprof
# Created by Zap installer
[ -f "${XDG_DATA_HOME:-$HOME/.local/share}/zap/zap.zsh" ] && source "${XDG_DATA_HOME:-$HOME/.local/share}/zap/zap.zsh"
plug "zsh-users/zsh-autosuggestions"
plug "zap-zsh/supercharge"
plug "zap-zsh/zap-prompt"
plug "zsh-users/zsh-syntax-highlighting"

# Load and initialise completion system
[ ! "$(find ~/.zcompdump -mtime 1)" ] || compinit
compinit -C

path=(
 ~/.local/bin 
 ~/.local/share/fnm
 ~/.npm-global/bin
 /usr/local/bin
 $path
)

# fnm
eval "$(fnm env --use-on-cd)"

export TSC_WATCHFILE=UseFsEvents
export TSC_NONPOLLING_WATCHER="1"
export COLORTERM=truecolor
export DISABLE_AUTO_TITLE='true'
export TERM='xterm-256color'
export EDITOR='nvim'
export VISUAL='nvim'


[[ -f "$HOME/.config/local/zsh/local.sh" ]] && source "$HOME/.config/local/zsh/local.sh"
[[ -f "$HOME/.config/zsh/aliases.sh" ]] && source "$HOME/.config/zsh/aliases.sh"

for file in $HOME/.config/zsh/includes/_*; do
    source "$file"
done

# zprof
