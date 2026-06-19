#!/bin/bash
#
# test-configured-languages.sh - run one (or more) test-suite target(s) for every
# target language that the current build was configured for with ./configure.
#
# Unlike a hardcoded language list, this discovers the configured subset from
# the generated top-level Makefile: configure substitutes @SKIP_<LANG>@ so that
# an enabled language has   skip-<lang> = test -n ""   (empty), while a disabled
# one has a non-empty value (e.g. test -n "1"). Only enabled languages are run.
#
# To mirror CI and catch warnings as errors, each language is built with the
# same CFLAGS/CXXFLAGS that the GitHub Actions Linux workflow uses, generated
# per language by Tools/testflags.py (which includes -Werror plus a per-language
# warning set). A new test should pass *and* be warning-clean everywhere, so any
# SWIG or C/C++ compiler warning becomes a hard build failure here. Pass
# --no-flags to fall back to plain make without these flags.
#
# Usage:
#   test-configured-languages.sh [options] TARGET [extra make args...]
#
# TARGET is a test-suite make target including its suffix, for example:
#   cpp11_alias_templates.cpptest   (C++ test)
#   li_cdata.ctest                  (C test)
#   imports.multicpptest            (multi-module C++ test)
#
# Examples:
#   test-configured-languages.sh cpp11_alias_templates.cpptest
#   test-configured-languages.sh -j 4 bools.cpptest
#   test-configured-languages.sh --std c++20 cpp20_concepts.cpptest
#   test-configured-languages.sh -x "c go" template_basic.cpptest
#   test-configured-languages.sh -o python,java li_std_vector.cpptest
#   test-configured-languages.sh --list
#
# Options:
#   -l, --list            List the configured languages and exit.
#   -o, --only LANGS      Run only these languages (space/comma separated).
#   -x, --exclude LANGS   Skip these languages (space/comma separated).
#   -j, --jobs N          Run up to N languages concurrently (default: 1).
#       --std CPPSTD      C++ standard for -std= (e.g. c++11, c++17, c++20).
#                         Default: auto-detected from a cppNN_ test name prefix,
#                         else c++17. The C standard is derived from it as CI
#                         does (c++11/14->c11, c++17/20->c17).
#       --cstd CSTD       Override the C standard (e.g. c11, gnu99, c17).
#       --compiler CC     Compiler passed to testflags.py: gcc (default) or
#                         clang; auto-detected from $CC if set.
#       --engine ENGINE   JavaScript engine (node, jsc, v8) passed as ENGINE=
#                         to the javascript run. Default: auto - use the
#                         configured engine, falling back from node to jsc/v8
#                         when node's test toolchain (npm) is unavailable.
#   -n, --no-flags        Do not set CFLAGS/CXXFLAGS; run plain make.
#   -v, --verbose         Verbose make (drop the -s flag).
#   -s, --stop            Stop at the first failing language.
#   -h, --help            Show this help.
#
# Exit status is the number of languages that failed (0 == all passed).

set -u

prog=$(basename "$0")

usage() {
  sed -n '3,/^# Exit status/p' "$0" | sed 's/^# \{0,1\}//'
  exit "${1:-0}"
}

# --- option parsing ---------------------------------------------------------
only=""
exclude=""
jobs=1
makeflags="-s"
stop_on_fail=0
list_only=0
use_flags=1
cppstd=""
cstd=""
compiler=""
engine_opt=""

while [ $# -gt 0 ]; do
  case "$1" in
    -l|--list)     list_only=1; shift ;;
    -o|--only)     only="$2"; shift 2 ;;
    -x|--exclude)  exclude="$2"; shift 2 ;;
    -j|--jobs)     jobs="$2"; shift 2 ;;
    --std)         cppstd="$2"; shift 2 ;;
    --cstd)        cstd="$2"; shift 2 ;;
    --compiler)    compiler="$2"; shift 2 ;;
    --engine)      engine_opt="$2"; shift 2 ;;
    -n|--no-flags) use_flags=0; shift ;;
    -v|--verbose)  makeflags=""; shift ;;
    -s|--stop)     stop_on_fail=1; shift ;;
    -h|--help)     usage 0 ;;
    --)            shift; break ;;
    -*)            echo "$prog: unknown option '$1'" >&2; usage 1 ;;
    *)             break ;;
  esac
done

# normalise comma separators to spaces
only=${only//,/ }
exclude=${exclude//,/ }

# --- locate the repo root (must contain a configured Makefile) --------------
find_root() {
  local d
  d=$(git rev-parse --show-toplevel 2>/dev/null)
  if [ -n "$d" ] && [ -f "$d/Makefile" ] && [ -d "$d/Examples/test-suite" ]; then
    echo "$d"; return 0
  fi
  d=$PWD
  while [ "$d" != "/" ]; do
    if [ -f "$d/Makefile" ] && [ -d "$d/Examples/test-suite" ] \
       && grep -q '^skip-python' "$d/Makefile" 2>/dev/null; then
      echo "$d"; return 0
    fi
    d=$(dirname "$d")
  done
  return 1
}

root=$(find_root) || {
  echo "$prog: could not find a configured SWIG build (no top-level Makefile with skip-<lang> markers)." >&2
  echo "$prog: run ./configure and make from the source tree first." >&2
  exit 2
}
makefile="$root/Makefile"
tsdir="$root/Examples/test-suite"

# --- discover configured languages from the generated Makefile --------------
# A language is enabled when its skip marker is empty: skip-<lang> = test -n ""
# 'errors' is a special diagnostics suite, not a target language - exclude it.
all_langs=$(sed -n 's/^skip-\([a-z0-9_]\{1,\}\)[[:space:]]*=[[:space:]]*test -n ""[[:space:]]*$/\1/p' "$makefile" \
            | grep -vx errors)

if [ -z "$all_langs" ]; then
  echo "$prog: no configured languages found in $makefile" >&2
  exit 2
fi

# apply --only / --exclude filters, preserving Makefile order
langs=""
for l in $all_langs; do
  if [ -n "$only" ]; then
    case " $only " in *" $l "*) ;; *) continue ;; esac
  fi
  if [ -n "$exclude" ]; then
    case " $exclude " in *" $l "*) continue ;; esac
  fi
  [ -d "$tsdir/$l" ] || { echo "$prog: warning: no test dir for '$l', skipping" >&2; continue; }
  langs="$langs $l"
done
langs=${langs# }

if [ "$list_only" -eq 1 ]; then
  echo "Configured languages (filters applied):"
  for l in $langs; do echo "  $l"; done
  exit 0
fi

# --- require a target -------------------------------------------------------
if [ $# -eq 0 ]; then
  echo "$prog: no test target given (e.g. cpp11_alias_templates.cpptest)" >&2
  usage 1
fi
target=$1   # first arg, used only for the summary heading

if [ -z "$langs" ]; then
  echo "$prog: no languages left to run after filtering" >&2
  exit 2
fi

# --- compiler / language standard setup (mirrors .github/workflows/linux.yml) -
# CI computes per-language CFLAGS/CXXFLAGS with Tools/testflags.py and passes
# them to make; the flags include -Werror so warnings fail the build.
testflags="$root/Tools/testflags.py"
if [ "$use_flags" -eq 1 ] && [ ! -f "$testflags" ]; then
  echo "$prog: $testflags not found; continuing without -Werror flags" >&2
  use_flags=0
fi
if [ "$use_flags" -eq 1 ] && ! command -v python3 >/dev/null 2>&1; then
  echo "$prog: python3 not found; continuing without testflags.py flags" >&2
  use_flags=0
fi

if [ "$use_flags" -eq 1 ]; then
  # compiler: honour --compiler, else infer from $CC, else gcc
  if [ -z "$compiler" ]; then
    case "${CC:-}" in
      *clang*) compiler=clang ;;
      *)       compiler=gcc ;;
    esac
  fi

  # C++ standard: honour --std, else auto-detect from a cppNN_ test name prefix
  if [ -z "$cppstd" ]; then
    case "$target" in
      cpp11_*) cppstd=c++11 ;;
      cpp14_*) cppstd=c++14 ;;
      cpp17_*) cppstd=c++17 ;;
      cpp20_*) cppstd=c++20 ;;
      cpp23_*) cppstd=c++23 ;;
      *)       cppstd=c++17 ;;   # safe modern default for non-prefixed tests
    esac
  fi

  # C standard: honour --cstd, else derive from the C++ standard as CI does
  if [ -z "$cstd" ]; then
    case "$cppstd" in
      c++11|c++14) cstd=c11 ;;
      *)           cstd=c17 ;;
    esac
  fi
fi

# Compute the testflags.py CFLAGS/CXXFLAGS for a language (empty if --no-flags).
lang_make_vars() {
  # prints zero or two shell-quoted make var assignments on stdout
  local l=$1 cf cxf
  [ "$use_flags" -eq 1 ] || return 0
  cf=$(python3 "$testflags" --language "$l" --cflags   --std="$cstd"   --compiler="$compiler" 2>/dev/null) || cf=""
  cxf=$(python3 "$testflags" --language "$l" --cxxflags --std="$cppstd" --compiler="$compiler" 2>/dev/null) || cxf=""
  printf 'CFLAGS=%s\nCXXFLAGS=%s\n' "$cf" "$cxf"
}

# Pick the JavaScript engine to use, mirroring the javascript test Makefile's
# precedence (node, then jsc, then v8) but only choosing node when its test
# toolchain is actually usable - node-gyp builds the wrapper and the Makefile
# calls 'npm config get prefix', so a missing npm makes the node engine fail.
# When node is not usable we read the configured fallback (jsc/v8) straight out
# of the generated Makefile, which is exactly what passing ENGINE=jsc by hand
# was working around.
detect_js_engine() {
  local jsmk="$tsdir/javascript/Makefile" nodejs jsc v8
  [ -f "$jsmk" ] || return 0
  nodejs=$(sed -n 's/^NODEJS[[:space:]]*=[[:space:]]*//p' "$jsmk" | head -1)
  if [ -n "$nodejs" ] && command -v node    >/dev/null 2>&1 \
                      && command -v node-gyp >/dev/null 2>&1 \
                      && command -v npm      >/dev/null 2>&1; then
    echo node; return 0
  fi
  # node unusable - read the configured jsc/v8 enable flags from the 'ifneq'
  # line immediately preceding each 'JSENGINE=<engine>' assignment.
  jsc=$(grep -B1 'JSENGINE=jsc' "$jsmk" | sed -n 's/.*ifneq[[:space:]]*(,[[:space:]]*\(.*\)).*/\1/p' | tr -d '[:space:]')
  v8=$(grep  -B1 'JSENGINE=v8'  "$jsmk" | sed -n 's/.*ifneq[[:space:]]*(,[[:space:]]*\(.*\)).*/\1/p' | tr -d '[:space:]')
  if   [ -n "$jsc" ]; then echo jsc
  elif [ -n "$v8" ];  then echo v8
  else echo node   # nothing better configured; let make run node and report
  fi
}

# --- run --------------------------------------------------------------------
logdir=$(mktemp -d "${TMPDIR:-/tmp}/swigtest.XXXXXX")
trap 'rm -rf "$logdir"' EXIT

# capture the full make argument list (target plus any extra make args)
make_args=("$@")

# Resolve the JavaScript engine if javascript is among the languages to run.
js_engine=""
js_engine_note=""
case " $langs " in
  *" javascript "*)
    if printf '%s\n' "${make_args[@]}" | grep -q '^ENGINE='; then
      js_engine_note="from command line"          # honour an explicit ENGINE=
    elif [ -n "$engine_opt" ]; then
      js_engine="$engine_opt"; js_engine_note="--engine"
    else
      js_engine=$(detect_js_engine); js_engine_note="auto"
    fi
    ;;
esac

run_lang() {
  local l=$1
  local -a mkvars=()
  if [ "$use_flags" -eq 1 ]; then
    mapfile -t mkvars < <(lang_make_vars "$l")
  fi
  if [ "$l" = javascript ] && [ -n "$js_engine" ]; then
    mkvars+=("ENGINE=$js_engine")
  fi
  ( make $makeflags -C "$tsdir/$l" "${make_args[@]}" "${mkvars[@]}" ) >"$logdir/$l.log" 2>&1
  echo $? >"$logdir/$l.rc"
}

echo "Target : $target"
echo "Root   : $root"
echo "Languages ($(echo $langs | wc -w)):$langs"
echo "Jobs   : $jobs"
if [ "$use_flags" -eq 1 ]; then
  echo "Flags  : testflags.py  (-Werror)  C++=$cppstd  C=$cstd  compiler=$compiler"
else
  echo "Flags  : none (--no-flags)"
fi
if [ -n "$js_engine_note" ]; then
  echo "JS     : ENGINE=${js_engine:-<command line>} ($js_engine_note)"
fi
echo "----------------------------------------------------------------------"

failed=""
passed=""

# print a language's captured build/run output, indented under a header
show_log() {
  echo "----- $1 output -----"
  sed 's/^/    | /' "$logdir/$1.log"
  echo "----------------------"
}

verbose=0
[ -z "$makeflags" ] && verbose=1

if [ "$jobs" -le 1 ]; then
  # serial: stream each language's result as it finishes
  for l in $langs; do
    printf '%-12s ... ' "$l"
    run_lang "$l"
    rc=$(cat "$logdir/$l.rc")
    if [ "$rc" -eq 0 ]; then
      echo "PASS"; passed="$passed $l"
      [ "$verbose" -eq 1 ] && show_log "$l"
    else
      echo "FAIL (exit $rc)"; failed="$failed $l"
      if [ "$verbose" -eq 1 ] || [ "$stop_on_fail" -eq 1 ]; then show_log "$l"; fi
      [ "$stop_on_fail" -eq 1 ] && break
    fi
  done
else
  # parallel: throttle to $jobs concurrent languages
  running=0
  declare -A pid_lang
  for l in $langs; do
    run_lang "$l" &
    pid_lang[$!]=$l
    running=$((running + 1))
    if [ "$running" -ge "$jobs" ]; then
      wait -n 2>/dev/null || wait
      running=$((running - 1))
    fi
  done
  wait
  for l in $langs; do
    rc=$(cat "$logdir/$l.rc" 2>/dev/null || echo 1)
    if [ "$rc" -eq 0 ]; then
      printf '%-12s PASS\n' "$l"; passed="$passed $l"
    else
      printf '%-12s FAIL (exit %s)\n' "$l" "$rc"; failed="$failed $l"
    fi
    { [ "$verbose" -eq 1 ] || { [ "$rc" -ne 0 ] && [ "$stop_on_fail" -eq 1 ]; }; } && show_log "$l"
  done
fi

# --- summary ----------------------------------------------------------------
echo "----------------------------------------------------------------------"
npass=$(echo $passed | wc -w)
nfail=$(echo $failed | wc -w)
echo "PASS: $npass  FAIL: $nfail"
if [ -n "$failed" ]; then
  echo "Failed:$failed"
  echo
  echo "Re-run a failing language to see its output, e.g.:"
  set -- $failed
  eng=""
  [ "$1" = javascript ] && [ -n "$js_engine" ] && eng=" ENGINE=$js_engine"
  if [ "$use_flags" -eq 1 ]; then
    fcf=$(python3 "$testflags" --language "$1" --cflags   --std="$cstd"   --compiler="$compiler" 2>/dev/null)
    fcx=$(python3 "$testflags" --language "$1" --cxxflags --std="$cppstd" --compiler="$compiler" 2>/dev/null)
    echo "  make -C $tsdir/$1 $target$eng CFLAGS=\"$fcf\" CXXFLAGS=\"$fcx\""
  else
    echo "  make -C $tsdir/$1 $target$eng"
  fi
fi

exit "$nfail"
