#!/bin/bash
# Expected to be called from elsewhere with certain variables set
# e.g. RETRY=travis-retry SWIGLANG=python GCC=7
set -e # exit on failure (same as -o errexit)

if [[ -n "$GCC" ]]; then
	$RETRY sudo add-apt-repository -y ppa:ubuntu-toolchain-r/test
	$RETRY sudo apt-get -qq update
	$RETRY sudo apt-get install -qq g++-$GCC
else
	$RETRY sudo apt-get -qq update
fi

$RETRY sudo apt-get -qq install libboost-dev libpcre3-dev
# Note: testflags.py needs python, but python is pre-installed

WITHLANG=$SWIGLANG

case "$SWIGLANG" in
	"")     ;;
	"javascript")
		case "$ENGINE" in
			"node"|"napi")
				$RETRY wget -qO- https://raw.githubusercontent.com/creationix/nvm/v0.33.10/install.sh | bash
				export NVM_DIR="$HOME/.nvm"
				[ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
				$RETRY nvm install ${VER}
				nvm use ${VER}
				if [ "$VER" == "0.10" ] || [ "$VER" == "0.12" ] || [ "$VER" == "4" ] || [ "$VER" == "6" ] ; then
#					$RETRY sudo apt-get install -qq nodejs node-gyp
					$RETRY npm install -g node-gyp@$VER
				elif [ "$VER" == "8" ] ; then
					$RETRY npm install -g node-gyp@6
				elif [ "$VER" == "10" ] || [ "$VER" == "12" ] || [ "$VER" == "14" ]  || [ "$VER" == "16" ]; then
					$RETRY npm install -g node-gyp@7
				else
					$RETRY npm install -g node-gyp
				fi
				$RETRY npm install -g node-addon-api
				;;
			"jsc")
				$RETRY sudo apt-get install -qq libjavascriptcoregtk-${VER}-dev
				;;
			"v8")
				$RETRY sudo apt-get install -qq libv8-dev
				;;
		esac
		;;
	"guile")
		$RETRY sudo apt-get -qq install guile-${VER:-2.0}-dev
		;;
	"mzscheme")
		$RETRY sudo apt-get -qq install racket
		;;
	"octave")
		if [[ "$VER" ]]; then
			$RETRY sudo add-apt-repository -y ppa:devacom/science
			$RETRY sudo apt-get -qq update
			$RETRY sudo apt-get -qq install "liboctave-dev=$VER.*"
		else
			$RETRY sudo apt-get -qq update
			$RETRY sudo apt-get -qq install liboctave-dev
		fi
		;;
	"python")
	  # Quick compatibility fix for old CI system
		WITHLANG=${SWIGLANG}3
		;;
	"scilab")
		if [[ -z "$VER" ]]; then
			$RETRY sudo apt-get -qq install scilab
		else
			# Starting with version 2023.0.0 the download filename format changed.
			case $VER in
				20*) scilab_tarball=scilab-$VER.bin.x86_64-pc-linux-gnu.tar.xz ;;
				*)   scilab_tarball=scilab-$VER.bin.linux-x86_64.tar.gz ;;
			esac
			$RETRY wget --progress=dot:giga "https://www.scilab.org/download/$VER/$scilab_tarball"
			# $HOME/.local/bin is in PATH and writeable
			mkdir -p "$HOME/.local"
			tar -xf "$scilab_tarball" --strip-components=1 -C "$HOME/.local"
		fi	
		;;
	"tcl")
		$RETRY sudo apt-get -qq install tcl-dev
		;;
esac

set +e # turn off exit on failure (same as +o errexit)
