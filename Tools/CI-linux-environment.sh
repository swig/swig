#!/bin/bash
# Expected to be called from elsewhere with same variables set as CI-linux-install.sh
# e.g. RETRY=travis-retry SWIGLANG=python
# Sets up environment for using various target languages
# For Github Actions where the environment is not preserved between steps
set -e # exit on failure (same as -o errexit)

case "$SWIGLANG" in
	"go")
		if [[ "$VER" ]]; then
		  eval "$($HOME/bin/gimme ${VER}.x)"
		  $HOME/bin/gimme --list
		fi
		;;
	"javascript")
		case "$ENGINE" in
			"node"|"napi")
				export NVM_DIR="$HOME/.nvm"
				[ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
				nvm use ${VER}
				;;
			*)      ;;
		esac
		;;
	"ruby")
		if ! command -v rvm; then
			set +x
			if [ -f /etc/profile.d/rvm.sh ] ; then
				source /etc/profile.d/rvm.sh
			elif [ -f $HOME/.rvm/scripts/rvm ] ; then
				source $HOME/.rvm/scripts/rvm
			fi
			set -x
		fi
		;;
	*)	;;
esac
