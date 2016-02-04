#!/bin/bash

set -e # exit on failure

lsb_release -a
sudo apt-get -qq update

if [[ "$CC" == gcc-5 ]]; then
	sudo add-apt-repository -y ppa:ubuntu-toolchain-r/test
	sudo add-apt-repository -y ppa:boost-latest/ppa
	sudo apt-get -qq update
	sudo apt-get install -qq g++-5 libboost1.55-dev
else
	sudo apt-get -qq install libboost-dev
fi

WITHLANG=$SWIGLANG

case "$SWIGLANG" in
	"")     ;;
	"csharp")
		sudo apt-get -qq install mono-devel
		;;
	"d")
		wget http://downloads.dlang.org/releases/2014/dmd_2.066.0-0_amd64.deb
		sudo dpkg -i dmd_2.066.0-0_amd64.deb
		;;
	"go")
		# Until configure.ac is fixed
		go env | sed -e 's/^/export /' > goenvsetup
		source goenvsetup
		rm -f goenvsetup
		;;
	"javascript")
		case "$ENGINE" in
			"node")
				sudo add-apt-repository -y ppa:chris-lea/node.js
				sudo apt-get -qq update
				sudo apt-get install -qq nodejs rlwrap
				sudo npm install -g node-gyp
				;;
			"jsc")
				sudo apt-get install -qq libwebkitgtk-dev
				;;
			"v8")
				sudo apt-get install -qq libv8-dev
				;;
		esac
		;;
	"guile")
		sudo apt-get -qq install guile-2.0-dev
		;;
	"lua")
		sudo apt-get -qq install lua5.1 liblua5.1-dev
		;;
	"ocaml")
		# configure also looks for ocamldlgen, but this isn't packaged.  But it isn't used by default so this doesn't matter.
		sudo apt-get -qq install ocaml ocaml-findlib
		;;
	"octave")
		if [[ -z "$VER" ]]; then
			sudo apt-get -qq install octave3.2 octave3.2-headers
		else
			sudo add-apt-repository -y ppa:kwwette/octaves
			sudo apt-get -qq update
			sudo apt-get -qq install liboctave${VER}-dev
		fi
		;;
	"php")
		sudo apt-get install php5-cli php5-dev
		;;
	"python")
		git clone https://github.com/jcrocholl/pep8.git
		(
			cd pep8
			git checkout tags/1.5.7
			python ./setup.py build
			sudo python ./setup.py install
		)
		if [[ "$PY3" ]]; then
			sudo apt-get install -qq python3-dev
		fi
		WITHLANG=$SWIGLANG$PY3
		if [[ "$VER" ]]; then
			sudo add-apt-repository -y ppa:fkrull/deadsnakes
			sudo apt-get -qq update
			sudo apt-get -qq install python${VER}-dev
			WITHLANG=$SWIGLANG$PY3=$SWIGLANG$VER
		fi
		;;
	"r")
		sudo apt-get -qq install r-base
		;;
	"ruby")
		if [[ "$VER" ]]; then
			sudo apt-get -qq install python-software-properties
			sudo add-apt-repository -y ppa:brightbox/ruby-ng
			sudo apt-get -qq update
			sudo apt-get -qq install ruby2.3 ruby2.3-dev
#			sudo gem pristine --all # Results in: You don't have write permissions for the /var/lib/gems/2.3.0 directory
			WITHLANG=$SWIGLANG=$SWIGLANG$VER
		fi
		;;
	"scilab")
		sudo apt-get -qq install scilab
		;;
	"tcl")
		sudo apt-get -qq install tcl8.4-dev
		;;
esac
