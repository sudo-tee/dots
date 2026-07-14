# Prevent plugins from running their own compinit
skip_global_compinit=1
setopt share_history
setopt HIST_VERIFY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt EXTENDED_HISTORY
setopt AUTO_CD
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt CORRECT
setopt NO_BEEP
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history

# PROFILING: Set the ZSH_PROFILE_STARTUP environment variable to enable profiling.
# if [ -n "${ZSH_PROFILE_STARTUP:+x}" ]; then
  zmodload zsh/zprof
# fi

[ -f "${XDG_DATA_HOME:-$HOME/.local/share}/zap/zap.zsh" ] && source "${XDG_DATA_HOME:-$HOME/.local/share}/zap/zap.zsh"

# Load and initialise completion system
autoload -Uz compinit 
if [[ ! -f ~/.zcompdump || -n "$(find ~/.zcompdump -mtime +1)" ]]; then
  compinit
else
  compinit -C
fi

# Created by Zap installer
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_USE_ASYNC=1
plug "romkatv/zsh-defer"
plug "zsh-users/zsh-autosuggestions"
plug "zap-zsh/zap-prompt"
plug "zsh-users/zsh-syntax-highlighting"
zsh-defer source ~/.local/share/zap/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.plugin.zsh


plug "zsh-users/zsh-history-substring-search"
bindkey '^[[A' history-substring-search-up
bindkey '^[OA' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey '^[OB' history-substring-search-down



path=(
 ~/.local/bin 
 ~/.local/share/fnm
 ~/.npm-global/bin
 /usr/local/bin
 ~/.cargo/bin
 /mnt/c/Windows/System32/WindowsPowerShell/v1.0
 $path
)

export TSC_WATCHFILE=UseFsEvents
export TSC_NONPOLLING_WATCHER="1"
export NODE_NO_WARNINGS=1
export COLORTERM=truecolor
export DISABLE_AUTO_TITLE='true'
export TERM='xterm-256color'
# export TERM='wezterm'
export EDITOR='nvim'
export VISUAL='nvim'

export USERPROFILE="/mnt/c/Users/fbelanger"

[[ -f "$HOME/.config/local/zsh/local.sh" ]] && source "$HOME/.config/local/zsh/local.sh"
[[ -f "$HOME/.config/local/zsh/secrets.sh" ]] && source "$HOME/.config/local/zsh/secrets.sh"
[[ -f "$HOME/.config/zsh/aliases.sh" ]] && source "$HOME/.config/zsh/aliases.sh"
[[ -f "$HOME/.config/zsh/ulimit.sh" ]] && source "$HOME/.config/zsh/ulimit.sh"
[[ -f "$HOME/.config/zsh/priv.sh" ]] && source "$HOME/.config/zsh/priv.sh"

for file in $HOME/.config/zsh/includes/_*; do
    source "$file"
done

# ... rest of your zshrc ...
 if [ -n "${ZSH_PROFILE_STARTUP:+x}" ]; then
  zprof
 fi


