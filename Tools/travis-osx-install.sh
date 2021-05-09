#!/bin/bash

# Install MacOS packages where the version has been overidden in .travis.yml

set -e # exit on failure (same as -o errexit)

# Disable 'brew cleanup', just wastes Travis job run time
export HOMEBREW_NO_INSTALL_CLEANUP=1

sw_vers
travis_retry brew update
echo "Installed packages..."
travis_retry brew list --versions
# travis_retry brew install pcre # Travis Xcode-7.3 has pcre
# travis_retry brew install boost

WITHLANG=$SWIGLANG

case "$SWIGLANG" in
	"cffi")
		export PATH=$HOME/.roswell/bin:$PATH
    	export ROSWELL_INSTALL_DIR=$HOME/.roswell
		travis_retry brew install roswell
		travis_retry ros install cffi
		travis_retry mkdir -p ${ROSWELL_INSTALL_DIR}/bin
		travis_retry cp Tools/cffi/cffi.ros ${ROSWELL_INSTALL_DIR}/bin/cffi.ros
		travis_retry chmod +x ${ROSWELL_INSTALL_DIR}/bin/cffi.ros
		;;
	"csharp")
		travis_retry brew install mono
		;;
	"lua")
		travis_retry brew install lua
		;;
	"octave")
		travis_retry Tools/brew-install octave
		;;
	"perl5")
		travis_retry Tools/brew-install perl
		;;
	"python")
		WITHLANG=$SWIGLANG$PY3
		;;
	"tcl")
		travis_retry Tools/brew-install --cask tcl
		;;
esac

# Workaround for https://github.com/travis-ci/travis-ci/issues/6522
set +e # turn off exit on failure (same as +o errexit)
