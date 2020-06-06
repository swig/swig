#!/bin/bash

# Install Linux packages where the version has been overidden in .travis.yml

set -e # exit on failure (same as -o errexit)

lsb_release -a
travis_retry sudo apt-get -qq update

if [[ -n "$GCC" ]]; then
	travis_retry sudo add-apt-repository -y ppa:ubuntu-toolchain-r/test
	travis_retry sudo apt-get -qq update
	travis_retry sudo apt-get install -qq g++-$GCC
fi

travis_retry sudo apt-get -qq install libboost-dev libpcre3-dev

WITHLANG=$SWIGLANG

case "$SWIGLANG" in
	"")     ;;
	"csharp")
		travis_retry sudo apt-get -qq install mono-devel
		;;
	"d")
		travis_retry wget http://downloads.dlang.org/releases/2.x/${VER}/dmd_${VER}-0_amd64.deb
		travis_retry sudo dpkg -i dmd_${VER}-0_amd64.deb
		;;
	"go")
		if [[ "$VER" ]]; then
		  eval "$(gimme ${VER}.x)"
		fi
		;;
	"javascript")
		case "$ENGINE" in
			"node")
				travis_retry wget -qO- https://raw.githubusercontent.com/creationix/nvm/v0.33.10/install.sh | bash
				export NVM_DIR="$HOME/.nvm"
				[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
				travis_retry nvm install ${VER}
				nvm use ${VER}
				if [ "$VER" == "0.10" ] || [ "$VER" == "0.12" ] || [ "$VER" == "4" ] || [ "$VER" == "6" ] ; then
#					travis_retry sudo apt-get install -qq nodejs node-gyp
					travis_retry npm install -g node-gyp@$VER
				elif [ "$VER" == "8" ] ; then
					travis_retry npm install -g node-gyp@6
				else
					travis_retry npm install -g node-gyp
				fi
				;;
			"jsc")
				travis_retry sudo apt-get install -qq libwebkitgtk-dev
				;;
			"v8")
				travis_retry sudo apt-get install -qq libv8-dev
				;;
		esac
		;;
	"guile")
		travis_retry sudo apt-get -qq install guile-2.0-dev
		;;
	"lua")
		if [[ -z "$VER" ]]; then
			travis_retry sudo apt-get -qq install lua5.2 liblua5.2-dev
		else
			travis_retry sudo apt-get -qq install lua${VER} liblua${VER}-dev
		fi
		;;
	"mzscheme")
		travis_retry sudo apt-get -qq install racket
		;;
	"ocaml")
		travis_retry sudo apt-get -qq install ocaml camlp4
		;;
	"octave")
		travis_retry sudo apt-get -qq install liboctave-dev
		;;
	"php")
		travis_retry sudo add-apt-repository -y ppa:ondrej/php
		travis_retry sudo apt-get -qq update
		travis_retry sudo apt-get -qq install php$VER-cli php$VER-dev
		;;
	"python")
		pip install --user pycodestyle
		if [[ "$PY3" ]]; then
			travis_retry sudo apt-get install -qq python3-dev
		fi
		WITHLANG=$SWIGLANG$PY3
		if [[ "$VER" ]]; then
			travis_retry sudo add-apt-repository -y ppa:deadsnakes/ppa
			travis_retry sudo apt-get -qq update
			travis_retry sudo apt-get -qq install python${VER}-dev
			WITHLANG=$SWIGLANG$PY3=$SWIGLANG$VER
		fi
		;;
	"r")
		travis_retry sudo apt-get -qq install r-base
		;;
	"ruby")
		if [[ "$VER" == "2.7" ]]; then
			# Ruby 2.7 support is currently only rvm master (30 Dec 2019)
			travis_retry rvm get master
			rvm reload
			rvm list known
		fi
		if [[ "$VER" ]]; then
			travis_retry rvm install $VER
		fi
		;;
	"scilab")
		# Travis has the wrong version of Java pre-installed resulting in error using scilab:
		# /usr/bin/scilab-bin: error while loading shared libraries: libjava.so: cannot open shared object file: No such file or directory
		echo "JAVA_HOME was set to $JAVA_HOME"
		unset JAVA_HOME
		travis_retry sudo apt-get -qq install scilab
		;;
	"tcl")
		travis_retry sudo apt-get -qq install tcl-dev
		;;
esac

set +e # turn off exit on failure (same as +o errexit)
