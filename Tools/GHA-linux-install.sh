#!/bin/bash

update_env()
{
	# Add variable to envirounment
	local var="$1"
	shift
	if [[ -n "$@" ]]; then
		echo "$var=$@" >> $GITHUB_ENV
	else
		echo "$var=true" >> $GITHUB_ENV
	fi
}
update_path()
{
	# Add new directory to 'PATH'
	echo "$@" >> $GITHUB_PATH
}

#lsb_release -a
# find location of current script (only works in bash)
script_dir="$( dirname "${BASH_SOURCE[0]}")"

# run generic script
RETRY=
source "$script_dir"/CI-linux-install.sh
