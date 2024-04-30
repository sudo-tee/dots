#!/bin/bash

# Set the directory where your projects are located
projects_directory="$HOME/Projects"

# Check if the projects directory exists
if [ ! -d "$projects_directory" ]; then
	echo "Projects directory not found: $projects_directory"
	exit 1
fi

# Check if a command argument is provided
if [ $# -lt 1 ]; then
	echo "Usage: $0 <command>"
	exit 1
fi

# The custom command (with {project} as a placeholder)
custom_command="$1"

# Loop through all subdirectories of the projects directory
for project_directory in "$projects_directory"/*/; do
	if [ -d "$project_directory" ]; then
		# Extract the project name from the project directory path
		project_name="$(basename "$project_directory")"

		# Replace {project} in the custom command with the actual project name
		command_to_run="${custom_command//\{project\}/$project_name}"

		echo "Running '$command_to_run' in $project_directory"
		(cd "$project_directory" && eval "$command_to_run")
		if [ $? -eq 0 ]; then
			echo "$command_to_run in $project_directory completed successfully"
		else
			echo "$command_to_run in $project_directory failed"
		fi
	fi
done
