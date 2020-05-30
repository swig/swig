#!/bin/bash

# Install MacOS packages where the version has been overidden in .travis.yml

set -e # exit on failure (same as -o errexit)

# Disable 'brew cleanup', just wastes Travis job run time
export HOMEBREW_NO_INSTALL_CLEANUP=1

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
	"octave")
		travis_retry Tools/brew-install octave
		;;
	"python")
		WITHLANG=$SWIGLANG$PY3
		;;
esac

# Workaround for https://github.com/travis-ci/travis-ci/issues/6522
set +e # turn off exit on failure (same as +o errexit)
