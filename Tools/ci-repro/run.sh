#!/bin/bash
# Build and drive the local GHA-Linux reproduction container.
#
# Auto-detects podman (preferred, rootless) or docker. Override with CONTAINER=.
# The SWIG working tree is bind mounted at /swig and built out of tree in a
# named volume, so the host tree stays clean apart from autogen output.
#
# Usage:
#   Tools/ci-repro/run.sh [--lang L] [--ver V] [--std S] build
#   Tools/ci-repro/run.sh [...] test <name> [<name> ...]   # e.g. li_std_functors
#   Tools/ci-repro/run.sh [...] ci                          # check-<lang>-test-suite
#   Tools/ci-repro/run.sh [...] shell                       # interactive shell
#
# Examples:
#   Tools/ci-repro/run.sh build
#   Tools/ci-repro/run.sh test li_std_functors
#   CONTAINER=docker Tools/ci-repro/run.sh --ver 3.4 ci
set -euo pipefail

LANG_=ruby
VER=3.3
STD=c++11
while [ $# -gt 0 ]; do
  case "$1" in
    --lang) LANG_=$2; shift 2 ;;
    --ver)  VER=$2;   shift 2 ;;
    --std)  STD=$2;   shift 2 ;;
    build|test|ci|shell) ACTION=$1; shift; break ;;
    *) echo "unknown option: $1" >&2; exit 2 ;;
  esac
done
ACTION=${ACTION:-build}

CONTAINER=${CONTAINER:-$(command -v podman || command -v docker || true)}
[ -n "$CONTAINER" ] || { echo "no podman or docker found - install one (e.g. sudo apt-get install podman)" >&2; exit 1; }
RT=$(basename "$CONTAINER")

HERE=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
REPO=$(cd "$HERE/../.." && pwd)
IMG=swig-ci-repro:${LANG_}-${VER}
VOL=swig-ci-repro-build-${LANG_}-${VER}

# podman needs :Z to relabel bind mounts for SELinux and keep-id to map the
# caller's uid into the container; docker (rootful) needs neither.
MOUNT_OPT=; USERNS=()
if [ "$RT" = podman ]; then MOUNT_OPT=:Z; USERNS=(--userns=keep-id); fi

build_image() {
  echo ">> building image $IMG with $RT"
  # Build context is Tools/ so the Dockerfile can COPY the CI install scripts
  # (Tools/CI-linux-*.sh) alongside ci-repro/entrypoint.sh.
  "$CONTAINER" build \
    --build-arg SWIGLANG="$LANG_" --build-arg VER="$VER" \
    --build-arg HOST_UID="$(id -u)" --build-arg HOST_GID="$(id -g)" \
    -f "$HERE/Dockerfile" -t "$IMG" "$HERE/.."
}

image_exists() { "$CONTAINER" image exists "$IMG" 2>/dev/null || "$CONTAINER" image inspect "$IMG" >/dev/null 2>&1; }

TEST_ARGS=
# Script run inside the container. Ensures swig is built out of tree (in the
# mounted build volume) the way CI does, then performs the requested action.
# Outer-shell variables are expanded here; \$(nproc) stays literal for the inner
# shell.
inner() {
  cat <<INNER
set -euo pipefail
cd /swig
[ -x ./configure ] || ./autogen.sh
mkdir -p /home/swig/build && cd /home/swig/build
[ -f Makefile ] || /swig/configure --without-alllang --with-${LANG_} CXXFLAGS="-std=${STD}"
make -s -j"\$(nproc)"
./swig -version | head -3
case "${ACTION}" in
  build) : ;;
  test)  cd Examples/test-suite/${LANG_} && make -s ${TEST_ARGS} ;;
  ci)    make check-${LANG_}-test-suite ;;
esac
INNER
}

run_container() {
  local interactive=()
  [ "$ACTION" = shell ] && interactive=(-it)
  "$CONTAINER" run --rm "${interactive[@]}" "${USERNS[@]}" \
    -v "$REPO":/swig${MOUNT_OPT} \
    -v "$VOL":/home/swig/build \
    -e SWIGLANG="$LANG_" -e VER="$VER" \
    "$IMG" "$@"
}

image_exists || build_image
case "$ACTION" in
  build) run_container bash -c "$(inner)" ;;
  ci)    run_container bash -c "$(inner)" ;;
  test)
    [ $# -gt 0 ] || { echo "test: give one or more test names, e.g. li_std_functors" >&2; exit 2; }
    TEST_ARGS=$(for t in "$@"; do printf '%s.cpptest ' "$t"; done)
    run_container bash -c "$(inner)" ;;
  shell) run_container bash ;;
  *) echo "unknown action: $ACTION" >&2; exit 2 ;;
esac
