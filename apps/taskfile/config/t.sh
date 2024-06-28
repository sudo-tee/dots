#!/bin/bash

task() {
	local dir=$PWD
	while [[ "$dir" != "" && ! -e "$dir/Taskfile" ]]; do
		dir=${dir%/*}
	done

	if [[ -n "$dir" ]]; then
		(
			cd "$dir"
			./Taskfile "$@"
		)
	else
		echo "No Taskfile found in directory or any of its ancestors"
		read -p "Do you want to initialize and create the Taskfile? (y/n): " ans
		if [[ $ans == [yY] || $ans == [yY][eE][sS] ]]; then
			init
		fi
	fi
}

init() {
	cp $HOME/.config/taskfile/Taskfile.template ./Taskfile &&
		chmod u+x ./Taskfile
}

task "$@"
