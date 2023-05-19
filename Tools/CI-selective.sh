#!/bin/bash
do_runTest()
{
  echo "Run test: $@"
  echo 'runTest=true' >> $GITHUB_OUTPUT
  exit
}
islang()
{
  local a="${1/\/*/}"
  local key="${a,,}"
  case "$key" in
    $ci_swiglang)
      do_runTest 'Found one of my language files'
      ;;
    tcl*) # Support tcl8 file name
      if [[ "$ci_swiglang" == "tcl" ]]; then
        do_runTest 'Found one of my language files'
      fi
      # TCL with other languges is ignored
      llang+=' tcl'
      ;;
    c|csharp|d|go|guile|java|javascript|lua|ocaml|octave|perl5|php|python|r|ruby|scilab)
      # other languges are ignored
      llang+=" $key"
      ;;
    schemerunme)
      case "$ci_swiglang" in
        guile)
          do_runTest 'Found a schemerunme file used by my language'
          ;;
      esac
      # schemerunme with other languages are ignored
      llang+=' schemerunme'
      ;;
    *)
      do_runTest 'Found a file belong to all languages'
      ;;
  esac
}
main()
{
  # Test is marked to always run
  if [[ -n "$ALWAYS_RUN" ]]; then
    do_runTest 'This Test always run!'
  fi
  # No Language test are always run
  if [[ -z "$SWIGLANG" ]]; then
    do_runTest 'Test without specific language always run'
  fi
  local file l llang ci_swiglang="${SWIGLANG,,}"
  for file in ${ALL_FILES}; do
    case "$file" in
    Examples/test-suite/*)
      islang "${file/Examples\/test-suite\//}"
      ;;
    Examples/*)
      islang "${file/Examples\//}"
      ;;
    Lib/*)
      islang "${file/Lib\//}"
      ;;
    Source/Modules/*)
      l="${file/\.cxx/}"
      islang "${l/Source\/Modules\//}"
      ;;
    *)
      do_runTest 'Found a file belong to all languages'
      ;;
    esac
  done
  echo 'Skip test: All files belong to other languages'
  if [[ -n "$llang" ]]; then
    echo "The other language are:$llang"
  fi
  echo 'runTest=skip' >> $GITHUB_OUTPUT
}
main
