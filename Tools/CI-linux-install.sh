#!/bin/bash
# Expected to be called from elsewhere with certain variables set
# e.g. RETRY=travis-retry SWIGLANG=python GCC=7

run_apt()
{
	$RETRY sudo apt-get -qq $@
}
add_apt_repository()
{
	$RETRY sudo add-apt-repository -y ppa:$1
}
probe_cached_tool()
{
	tool_path=$(ls -d /opt/hostedtoolcache/$1/$VER.*/x64/bin 2> /dev/null | head -1 || true)
}

if [[ "$compiler" = 'clang' ]]; then
	run_apt update
	CC="clang"
	CXX="clang++"
elif [[ -n "$GCC" ]]; then
	add_apt_repository ubuntu-toolchain-r/test
	run_apt update
	run_apt install g++-$GCC
	CC="gcc-$GCC"
	CXX="g++-$GCC"
else
	run_apt update
	CC="gcc"
	CXX="g++"
fi
update_env 'CC' "$CC"
update_env 'CXX' "$CXX"
ls -la $(which $CC) $(which $CXX)
$CC --version
$CXX --version

run_apt install libboost-dev libpcre3-dev
# Note: testflags.py needs python, but python is pre-installed

WITHLANG=$SWIGLANG

case "$SWIGLANG" in
	"")     ;;
	"csharp")
		run_apt install mono-devel
		;;
	"d")
		if [[ $VER =~ ^2\. ]]; then
			$RETRY wget http://downloads.dlang.org/releases/2.x/${VER}/dmd_${VER}-0_amd64.deb
			$RETRY sudo dpkg -i dmd_${VER}-0_amd64.deb
		else
			run_apt install "$VER"
		fi
		;;
	"go")
		if [[ "$VER" ]]; then
			# Check if Go is already installed on cached tools
			probe_cached_tool 'go'
			if [[ -n "$tool_path" ]] && [[ -d "$tool_path" ]]; then
				update_path "$tool_path"
			else
				mkdir -p $HOME/bin
				curl -sL -o $HOME/bin/gimme https://raw.githubusercontent.com/travis-ci/gimme/master/gimme
				chmod +x $HOME/bin/gimme
				eval "$($HOME/bin/gimme ${VER}.x)"
				$HOME/bin/gimme --list
			fi
		fi
		;;
	"java")
		if [[ -n "$VER" ]]; then
			java_path="JAVA_HOME_${VER}_X64"
			update_env 'JAVA_HOME' "${!java_path}"
		fi
		;;
	"javascript")
		case "$ENGINE" in
			"node"|"napi")
				if [[ -n "$VER" ]]; then
					if [[ "$ENGINE" = "node" ]]; then
						# Works with node only
						probe_cached_tool 'node'
					fi
					if [[ -n "$tool_path" ]] && [[ -d "$tool_path" ]]; then
						update_path "$tool_path"
					else
						$RETRY wget -qO- https://raw.githubusercontent.com/creationix/nvm/v0.33.10/install.sh | bash
						[ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
						$RETRY nvm install ${VER}
						nvm use ${VER}
						update_env 'USE_NVM'
					fi
					case "$VER" in
						0.10|0.12|4|6)
							# run_apt install nodejs node-gyp
							$RETRY npm install -g node-gyp@$VER
							;;
						8)
							$RETRY npm install -g node-gyp@6
							;;
						10|12|14|16)
							$RETRY npm install -g node-gyp@7
							;;
						*)
							$RETRY npm install -g node-gyp
							;;
					esac
				else
					$RETRY npm install -g node-gyp
				fi
				$RETRY npm install -g node-addon-api
				;;
			"jsc")
				run_apt install libjavascriptcoregtk-${VER}-dev
				;;
			"v8")
				run_apt install libnode-dev
				;;
		esac
		;;
	"guile")
		run_apt install guile-${VER:-2.2}-dev
		;;
	"lua")
		if [[ -z "$VER" ]]; then
			run_apt install lua5.2 liblua5.2-dev
		else
			run_apt install lua${VER} liblua${VER}-dev
		fi
		;;
	"ocaml")
		run_apt install ocaml camlp4
		;;
	"octave")
		if [[ "$VER" ]]; then
			run_apt update
			run_apt install "octave-dev=$VER.*"
		else
			run_apt update
			run_apt install octave-dev
		fi
		;;
	"php")
		if [[ "$VER" ]]; then
			if ! dpkg -l  'php*' | grep "^ii  php$VER" > /dev/null; then
				# Remove installed PHP, as we need another version
				run_apt remove "php*-cli" "php*-dev"
				add_apt_repository ondrej/php
				run_apt update
				run_apt install php$VER-cli php$VER-dev
			fi
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
			if [[ -z "$PY2" ]] && [[ $VER =~ ^[0-9.]+$ ]]; then
				# Check if Python is already installed on cached tools
			    probe_cached_tool 'Python'
			fi
			if [[ -n "$tool_path" ]] && [[ -d "$tool_path" ]]; then
				update_path "$tool_path"
			else
				add_apt_repository deadsnakes/ppa
				run_apt update
				case "$VER" in
					*-dbg)
						run_apt install python${VER::-4}-dev python${VER}
					  ;;
					*t)
						run_apt install python${VER::-1}-dev python${VER::-1}-nogil
					  ;;
					*)
						run_apt install python${VER}-dev
					;;
				esac
			fi
			WITHLANG="$WITHLANG=$SWIGLANG$VER"
		elif [[ "$PY2" ]]; then
			run_apt install python2-dev
		fi
		;;
	"r")
		run_apt install r-base
		;;
	"ruby")
		if [[ "$VER" ]]; then
			# Check if ruby is already installed on cached tools
			probe_cached_tool 'Ruby'
			if [[ -n "$tool_path" ]] && [[ -d "$tool_path" ]]; then
				update_path "$tool_path"
			else
				case "$VER" in
					2.5 | 2.7 | 3.0 | 3.1 | 3.2 | 3.3 )
						# Ruby 3.1+ support is currently only rvm master (2023-04-19)
						# YOLO
						#
						# Ruby 2.5, 2.7 and 3.0 work with this
						# rvm but no longer seem to with the
						# PPA rvm.  2.4 and 2.6 fail with either.
						# (2025-06-18)
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
						add_apt_repository rael-gc/rvm
						run_apt -qq update
						run_apt -qq install rvm
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
		fi
		;;
	"scilab")
		if [[ -z "$VER" ]]; then
			run_apt install scilab
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
		run_apt install tcl-dev
		;;
esac
update_env 'WITHLANG' "$WITHLANG"
