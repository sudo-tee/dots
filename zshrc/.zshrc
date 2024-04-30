# Created by Zap installer
[ -f "${XDG_DATA_HOME:-$HOME/.local/share}/zap/zap.zsh" ] && source "${XDG_DATA_HOME:-$HOME/.local/share}/zap/zap.zsh"
plug "zsh-users/zsh-autosuggestions"
plug "zap-zsh/supercharge"
plug "zap-zsh/zap-prompt"
plug "zsh-users/zsh-syntax-highlighting"

# Load and initialise completion system
autoload -Uz compinit
compinit

[[ -f "$HOME/.config/zsh/aliases.sh" ]] && source "$HOME/.config/zsh/aliases.sh"
[[ -f "$HOME/.config/work/work.sh" ]] && source "$HOME/.config/work/work.sh"

path=(
 ~/.local/bin 
 ~/.local/share/fnm
 ~/.npm-global/bin
 /usr/local/bin
 $path
)

# fnm
eval "`fnm env`"


export TSC_WATCHFILE=UseFsEvents
export TSC_NONPOLLING_WATCHER="1"
export COLORTERM=truecolor
export DISABLE_AUTO_TITLE='true'
export TERM='xterm-256color'
export EDITOR='nvim'
export VISUAL='nvim'




