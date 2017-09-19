#!/bin/bash

set -e # exit on failure (same as -o errexit)

sw_vers
travis_retry brew update
travis_retry brew list
# travis_retry brew install pcre # Travis Xcode-7.3 has pcre
# travis_retry brew install boost

WITHLANG=$SWIGLANG

case "$SWIGLANG" in
	"csharp")
		travis_retry brew install mono
		;;
	"guile")
		travis_retry Tools/brew-install guile
		;;
	"lua")
		travis_retry brew install lua
		;;
	"python")
		WITHLANG=$SWIGLANG$PY3
		if [[ "$PY3" ]]; then
			travis_retry brew install python3
			travis_retry brew list -v python3
		fi
		;;
esac

# Workaround for https://github.com/travis-ci/travis-ci/issues/6522
set +e # turn off exit on failure (same as +o errexit)
