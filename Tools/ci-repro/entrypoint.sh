#!/bin/bash
# Reconstruct the GHA step environment inside the container, then exec the
# command. GitHub Actions does not preserve a shell between steps; it replays
# $GITHUB_ENV and $GITHUB_PATH that the install step wrote. We do the same, plus
# source RVM so a target language installed under $HOME is on PATH.
set -e

# RVM (ruby). Harmless if not installed.
if [ -s "$HOME/.rvm/scripts/rvm" ]; then
  source "$HOME/.rvm/scripts/rvm"
fi

# Exported variables the install recorded (CC, CXX, WITHLANG, ...).
if [ -f "$HOME/gha_env" ]; then
  set -a
  source "$HOME/gha_env"
  set +a
fi

# PATH additions the install recorded (go, node, ...).
if [ -f "$HOME/gha_path" ] && [ -s "$HOME/gha_path" ]; then
  export PATH="$(paste -sd: "$HOME/gha_path"):$PATH"
fi

exec "$@"
