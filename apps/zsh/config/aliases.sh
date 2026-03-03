alias zr="source ~/.zshrc"
alias za="source $HOME/.config/zsh/includes/_aliases.sh"
alias cl="clear"
alias ..="cd .."
alias ...="cd ../.."
alias .3="cd ../../.."
alias .4="cd ../../../.."

g() {
  git "$@"
}

function ls() {
  command ls -lh --color=auto "$@"
}

alias up="sudo apt update && sudo apt dist-upgrade"

# function aliases
urldecode() {
  echo "$1" | python3 -c "import sys; from urllib.parse import unquote; print(unquote(sys.stdin.read()));"
}

urlencode() {
  echo "$1" | python3 -c "import sys; from urllib.parse import quote; print(quote(sys.stdin.read()));"
}

alias urld="urldecode"
alias urle="urlencode"

mkcd() {
  mkdir -p $1
  cd "$1" || exit
}

zsh-fix-history() {
  mv ~/.zsh_history ~/.zsh_history_bad
  strings ~/.zsh_history_bad >~/.zsh_history
  fc -R ~/.zsh_history
  rm ~/.zsh_history_bad
}

# What the port
wtp() {
  if [ -z "$1" ]; then
    echo "Usage: wtp [-p][-k] port_number"
    return 1
  fi

  local pid_flag kill_flag
  if [[ "$1" == "-p" ]]; then
    shift
    pid_flag=1
  fi
  if [[ "$1" == "-k" ]]; then
    if [[ -n "$pid_flag" ]]; then
      echo "You cannot use the -p flag and the -k flag at the same time"
      return 1
    fi
    shift
    kill_flag=1
  fi

  local port="$1"

  _wtp_get_pids() {
    sudo fuser "${1}/tcp" 2>/dev/null | tr ' ' '\n' | grep -v '^$'
  }

  if [[ -n "$pid_flag" ]]; then
    _wtp_get_pids "$port"

  elif [[ -n "$kill_flag" ]]; then
    local pids
    pids=$(_wtp_get_pids "$port")
    if [[ -n "$pids" ]]; then
      echo "Killing PID(s): $pids"
      echo "$pids" | xargs sudo kill -9
    else
      echo "No process found listening on port $port"
      return 1
    fi

  else
    local pids
    pids=$(_wtp_get_pids "$port")
    if [[ -z "$pids" ]]; then
      echo "No process found listening on port $port"
      return 1
    fi
    printf "%-10s %-20s %s\n" "PID" "COMMAND" "USER"
    while IFS= read -r pid; do
      local cmd user
      cmd=$(cat "/proc/$pid/comm" 2>/dev/null || echo "?")
      user=$(stat -c '%U' "/proc/$pid" 2>/dev/null || echo "?")
      printf "%-10s %-20s %s\n" "$pid" "$cmd" "$user"
    done <<<"$pids"
  fi
}

hextorgb() {
  : "${1/\#/}"
  ((r = 16#${_:0:2}, g = 16#${_:2:2}, b = 16#${_:4:2}))
  printf '%s\n' "$r $g $b"
}

rgbtohex() {
  printf '#%02x%02x%02x\n' "$1" "$2" "$3"
}

nkill() {
  local count=0
  local dirs=()

  echo "Searching for node_modules directories..."

  while IFS= read -r dir; do
    [[ -n "$dir" ]] && dirs+=("$dir")
  done < <(find . -maxdepth 3 -name "node_modules" -type d -prune)

  count=${#dirs[@]}

  if ((count == 0)); then
    echo "No node_modules directories found."
    return 0
  fi

  echo "Found $count node_modules director$( ((count == 1)) && echo "y" || echo "ies"):"
  printf '  %s\n' "${dirs[@]}"

  echo -n "Do you want to delete these directories? [y/N] "
  read -r REPLY
  echo

  if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Deleting directories..."
    for dir in "${dirs[@]}"; do
      if rm -rf "$dir" 2>/dev/null; then
        echo "✓ Deleted: $dir"
      else
        echo "✗ Failed to delete: $dir"
      fi
    done
    echo "Operation completed!"
  else
    echo "Operation cancelled."
  fi
}
