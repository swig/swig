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
# See list of cached tools in:
# https://github.com/actions/runner-images/blob/main/images/ubuntu/Ubuntu2404-Readme.md#cached-tools
# Use 'SKIP_CACHED_TOOLS' to skip the cached tools
probe_cached_tool()
{
	if [[ -z "$SKIP_CACHED_TOOLS" ]]; then
		tool_path=$(ls -d $RUNNER_TOOL_CACHE/$1/$VER.*/x64/bin 2> /dev/null | head -1 || true)
	fi
}

#lsb_release -a
# find location of current script (only works in bash)
script_dir="$( dirname "${BASH_SOURCE[0]}")"

# run generic script
RETRY=
source "$script_dir"/CI-linux-install.sh
