alias zr="source ~/.zshrc"
alias za="source $HOME/.config/zsh/aliases.sh"
alias cl="clear"
alias ..="cd .."
alias ...="cd ../.."
alias .3="cd ../../.."
alias .4="cd ../../../.."

alias up="sudo dnf distro-sync"

if [[ -f "/usr/local/bin/win32yank.exe" ]]; then
	alias pbcopy='win32yank.exe -i --crlf'
	alias pbpaste='win32yank.exe -o --lf'
fi

# function aliases
function urldecode() {
	echo "$1" | python3 -c "import sys; from urllib.parse import unquote; print(unquote(sys.stdin.read()));"
}

function urlencode() {
	echo "$1" | python3 -c "import sys; from urllib.parse import quote; print(quote(sys.stdin.read()));"
}

mkcd() {
	mkdir -p $1
	cd $1
}

wtp() {
	lsof -i -P -n | grep LISTEN | grep :$1
}

hextorgb() {
	: "${1/\#/}"
	((r = 16#${_:0:2}, g = 16#${_:2:2}, b = 16#${_:4:2}))
	printf '%s\n' "$r $g $b"
}

rgbtohex() {
	printf '#%02x%02x%02x\n' "$1" "$2" "$3"
}

alias urld="urldecode"
alias urle="urlencode"

ucd() {
	local search_term="${1:-}"
	local command="${2:-cd}"
	local dir="$(fd "$search_term" /home/francis/Projects -t d -t l -d 1 --exclude .git | fzf --reverse --select-1)"
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
