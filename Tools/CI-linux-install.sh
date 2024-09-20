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
	"csharp")
		$RETRY sudo apt-get -qq install mono-devel
		;;
	"d")
		if [[ $VER =~ ^2\. ]]; then
			$RETRY wget http://downloads.dlang.org/releases/2.x/${VER}/dmd_${VER}-0_amd64.deb
			$RETRY sudo dpkg -i dmd_${VER}-0_amd64.deb
		else
			$RETRY sudo apt-get -qq install "$VER"
		fi
		;;
	"go")
		if [[ "$VER" ]]; then
		  mkdir -p $HOME/bin
		  curl -sL -o $HOME/bin/gimme https://raw.githubusercontent.com/travis-ci/gimme/master/gimme
		  chmod +x $HOME/bin/gimme
		  eval "$($HOME/bin/gimme ${VER}.x)"
		  $HOME/bin/gimme --list
		fi
		;;
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
				$RETRY sudo apt-get install -qq libnode-dev
				;;
		esac
		;;
	"guile")
		$RETRY sudo apt-get -qq install guile-${VER:-2.0}-dev
		;;
	"lua")
		if [[ -z "$VER" ]]; then
			$RETRY sudo apt-get -qq install lua5.2 liblua5.2-dev
		else
			$RETRY sudo apt-get -qq install lua${VER} liblua${VER}-dev
		fi
		;;
	"mzscheme")
		$RETRY sudo apt-get -qq install racket
		;;
	"ocaml")
		$RETRY sudo apt-get -qq install ocaml camlp4
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
	"php")
		if [[ "$VER" ]]; then
			$RETRY sudo apt-get -qq remove "php*-cli" "php*-dev" # Multiple versions are pre-installed
			$RETRY sudo add-apt-repository -y ppa:ondrej/php
			$RETRY sudo apt-get -qq update
			$RETRY sudo apt-get -qq install php$VER-cli php$VER-dev
		fi
		;;
	"python")
		pip install --user pycodestyle
		if [[ "$PY_ABI_VER" ]]; then
			# assertion in abi3audit 0.0.11, fixed in 0.0.12
			pip install --user 'abi3audit>=0.0.12'
		fi
		if [[ "$PY2" ]]; then
			WITHLANG=$SWIGLANG
		else
			WITHLANG=${SWIGLANG}3
		fi
		if [[ "$VER" ]]; then
			$RETRY sudo add-apt-repository -y ppa:deadsnakes/ppa
			$RETRY sudo apt-get -qq update
			$RETRY sudo apt-get -qq install python${VER}-dev
			WITHLANG=$WITHLANG=$SWIGLANG$VER
		elif [[ "$PY2" ]]; then
			$RETRY sudo apt-get install -qq python-dev
		else
			$RETRY sudo apt-get install -qq python3-dev
		fi
		;;
	"r")
		$RETRY sudo apt-get -qq install r-base
		;;
	"ruby")
		if [[ "$VER" ]]; then
			case "$VER" in
				3.1 | 3.2 | 3.2.2 | 3.3 )
					# Ruby 3.1+ support is currently only rvm master (2023-04-19)
					# YOLO
					curl -sSL https://rvm.io/mpapis.asc | gpg --import -
					curl -sSL https://rvm.io/pkuczynski.asc | gpg --import -
					curl -sSL https://get.rvm.io | bash -s stable
					set +x
					source $HOME/.rvm/scripts/rvm
					$RETRY rvm get master
					rvm reload
					rvm list known
					set -x
					;;
				* )
					# Install from PPA as that also contains packages needed for the build.
					sudo apt-add-repository -y ppa:rael-gc/rvm
					sudo apt-get update
					sudo apt-get install rvm
					sudo usermod -a -G rvm $USER
					set +x
					source /etc/profile.d/rvm.sh
					set -x
					;;
			esac
			set +x
			$RETRY rvm install $VER
			set -x
		fi
		;;
	"scilab")
		if [[ -z "$VER" ]]; then
			$RETRY sudo apt-get -qq install scilab
		else
			# Starting with version 2023.0.0 the download filename format changed.
			case $VER in
				2023.0*) scilab_tarball=scilab-$VER.bin.x86_64-pc-linux-gnu.tar.xz ;;
				20*) scilab_tarball=scilab-$VER.bin.x86_64-linux-gnu.tar.xz ;;
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
