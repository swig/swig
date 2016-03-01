#!/bin/bash

set -e # exit on failure

sw_vers
brew update
brew list
brew install pcre
# brew install boost

WITHLANG=$SWIGLANG

case "$SWIGLANG" in
	"csharp")
		brew install https://s3.amazonaws.com/travisbuilds.swig.org/mono.rb
		;;
	"guile")
		Tools/brew-install guile
		;;
	"lua")
		brew install lua
		;;
	"python")
		WITHLANG=$SWIGLANG$PY3
		if [[ "$PY3" ]]; then
			brew install python3
			brew list -v python3
		fi
		;;
esac
