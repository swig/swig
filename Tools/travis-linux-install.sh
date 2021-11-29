#!/bin/bash

# Install Linux packages where the version has been overridden in .travis.yml

lsb_release -a
# find location of current script (only works in bash)
script_dir="$( dirname "${BASH_SOURCE[0]}")"

# run generic script
RETRY=travis-retry
source "$script_dir"/CI-linux-install.sh
