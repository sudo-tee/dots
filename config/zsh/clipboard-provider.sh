#!/bin/bash
#
# clipboard provider for neovim
#
# :help provider-clipboard

#exec 2>> ~/clipboard-provider.out
#set -x

: ${COPY_PROVIDERS:=tmux osc52}
: ${PASTE_PROVIDERS:=tmux}
: ${TTY:=$( (tty || tty </proc/$PPID/fd/0) 2>/dev/null | grep /dev/)}

main() {
	declare p status=99

	case $1 in
	copy)
		slurp
		for p in $COPY_PROVIDERS; do
			$p-provider copy && status=0
		done
		;;

	paste)
		for p in $PASTE_PROVIDERS; do
			$p-provider paste && status=0 && break
		done
		;;
	esac

	exit $status
}

# N.B. buffer is global for simplicity
slurp() { buffer=$(base64); }
spit() { base64 --decode <<<"$buffer"; }

tmux-provider() {
	[[ -n $TMUX ]] || return
	case $1 in
	copy) spit | tmux load-buffer - ;;
	paste) tmux save-buffer - ;;
	esac
}

osc52-provider() {
	case $1 in
	copy) [[ -n "$TTY" ]] && printf $'\e]52;c;%s\a' "$buffer" >"$TTY" ;;
	paste) return 1 ;;
	esac
}

main "$@"
