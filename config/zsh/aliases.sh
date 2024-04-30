alias zr="source ~/.zshrc"
alias za="source $HOME/.config/zsh/includes/_aliases.sh"
alias cl="clear"
alias ..="cd .."
alias ...="cd ../.."
alias .3="cd ../../.."
alias .4="cd ../../../.."

alias g=git

alias nvim="IS_NVIM=true ~/.local/share/bob/nvim-bin/nvim"

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

ucd() {
	local search_term="${1:-}"
	local command="${2:-cd}"
	local dir="$(fdfind "$search_term" "$HOME/Projects" -t d -t l -d 1 --exclude .git | fzf --reverse --select-1)"
	if [ -n "$dir" ]; then
		"$command" "$dir"
	fi
}

git_branch() {
	echo $(git symbolic-ref --short -q HEAD)
}

git_rebase_current_branch() {
	# Check if there are unstaged changes
	if [[ -n $(git status --porcelain) ]]; then

		stash_name="main-rebase-stash-$(date +'%Y%m%d%H%M%S')-$(shuf -i 1000-9999 -n 1)"

		# Prompt the user if they want to stash the changes
		select choice in "Stash changes" "Abort rebase"; do
			case $REPLY in
			1)
				# Stash the changes
				git stash
				break
				;;
			2)
				# Abort the rebase
				echo "Aborting rebase."
				return 1
				;;
			*)
				echo "Invalid choice. Please select a valid option."
				;;
			esac
		done </dev/tty
	fi

	# Check for existing branches (main or master)
	if git rev-parse --verify --quiet master; then
		MAIN_BRANCH="master"
	else
		if git rev-parse --verify --quiet main; then
			MAIN_BRANCH="main"
		else
			echo "Neither 'master' nor 'main' branch found."
			return 1
		fi
	fi

	# Fetch the new changes from the upstream repository
	git fetch origin $MAIN_BRANCH:$MAIN_BRANCH

	# Rebase the current branch on top of the updated upstream branch
	git rebase $MAIN_BRANCH

	# Reapply the named stash if it exists
	if [[ -n $stash_name ]]; then
		git stash apply stash@{$stash_name}
	fi
}
