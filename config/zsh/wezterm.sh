# This function emits an OSC 1337 sequence to set a user var
# associated with the current terminal pane.
# It requires the `base64` utility to be available in the path.
# This function is included in the wezterm shell integration script, but
# is reproduced here for clarity
__wezterm_set_user_var() {
	if hash base64 2>/dev/null; then
		if [[ -z "${TMUX}" ]]; then
			printf "\033]1337;SetUserVar=%s=%s\007" "$1" $(echo -n "$2" | base64) >/dev/fd/2
		else
			# <https://github.com/tmux/tmux/wiki/FAQ#what-is-the-passthrough-escape-sequence-and-how-do-i-use-it>
			# Note that you ALSO need to add "set -g allow-passthrough on" to your tmux.conf
			printf "\033Ptmux;\033\033]1337;SetUserVar=%s=%s\007\033\\" "$1" $(echo -n "$2" | base64) >/dev/fd/2
		fi
	fi
}

wezterm_set_user_var() {
	if hash base64 2>/dev/null; then
		if [[ -z "${TMUX}" ]]; then
			printf "\033]1337;SetUserVar=%s=%s\007" "$1" $(echo -n "$2" | base64) 2>&1
		else
			# <https://github.com/tmux/tmux/wiki/FAQ#what-is-the-passthrough-escape-sequence-and-how-do-i-use-it>
			# Note that you ALSO need to add "set -g allow-passthrough on" to your tmux.conf
			printf "\033Ptmux;\033\033]1337;SetUserVar=%s=%s\007\033\\" "$1" $(echo -n "$2" | base64) 2>&1
		fi
	fi
}

wezterm_send_user_command() {
	if hash base64 2>/dev/null; then
		if [[ -z "${TMUX}" ]]; then
			printf "\033]1337;SetUserVar=%s=%s\007" "uc" $(echo -n "{\"c\":\"$1\",\"v\":\"$2\"}" | base64) 2>&1
		else
			# <https://github.com/tmux/tmux/wiki/FAQ#what-is-the-passthrough-escape-sequence-and-how-do-i-use-it>
			# Note that you ALSO need to add "set -g allow-passthrough on" to your tmux.conf
			printf "\033Ptmux;\033\033]1337;SetUserVar=%s=%s\007\033\\" "$1" $(echo -n "$2" | base64) 2>&1
		fi
	fi
}

function _run_prog() {
	export WEZTERM_PROG="$1"
	# set PROG to the program being run
	__wezterm_set_user_var "PROG" "$1"

	# arrange to clear it when it is done
	trap '__wezterm_set_user_var PROG ""' EXIT
	trap 'export WEZTERM_PROG=""' EXIT

	# and now run the corresponding command, taking care to avoid looping
	# with the alias definition
	command "$@"
}

function cd() {
	builtin cd "$@"
	printf "\033]7;file://%s%s\033\\" "${HOSTNAME}" "${PWD}"
}
