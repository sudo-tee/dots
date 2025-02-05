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

  local pid_flag
  if [[ "$1" == "-p" ]]; then
    shift
    pid_flag=1
  fi

  local kill_flag
  if [[ "$1" == "-k" ]]; then
    if [[ -n "$pid_flag" ]]; then
      echo "You cannot use the -p flag and the -k flag at the same time"
      return 1
    fi
    shift
    kill_flag=1
  fi

  if [ -n "$pid_flag" ]; then
    sudo lsof -i:$1 -t
  elif [[ -n "$kill_flag" ]]; then
    kill -9 $(sudo lsof -i:$1 -t)
  else
    sudo lsof -i:$1
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
  local dirs
  dirs=$(find . -maxdepth 3 -name "node_modules" -type d)

  if [ -z "$dirs" ]; then
    echo "No top-level node_modules directories found."
    return 0
  fi

  echo "Found top-level node_modules directories:"
  echo "$dirs"
  echo

  echo -n "Do you want to delete these directories? [y/N] "
  read -k 1 REPLY
  echo

  if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Deleting directories..."
    while IFS= read -r dir; do
      rm -rf "$dir"
      echo "✓ Deleted: $dir"
    done <<<"$dirs"
    echo "Done!"
  else
    echo "Operation cancelled."
  fi
}
