#!/bin/bash

#lsb_release -a
# find location of current script (only works in bash)
script_dir="$( dirname "${BASH_SOURCE[0]}")"

# run generic script
RETRY=
source "$script_dir"/CI-linux-install.sh
