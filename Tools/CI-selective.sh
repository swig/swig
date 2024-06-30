#!/bin/bash
islang()
{
  case "$1" in
    csharp|d|go|guile|java|javascript|lua|mzscheme|ocaml|octave|perl5|php|python|r|ruby|scilab|tcl)
      isLang=true
      ;;
    *)
      isLang=flase
      ;;
  esac
}
main()
{
  local m l isLang=true
  if [[ -z "$SWIGLANG" ]]; then
    # No language, run CI
    #echo exit 0
    echo "No SWIGLANG"
  fi
  cd $GITHUB_WORKSPACE
  readarray <<< $(git diff origin/$GITHUB_BASE_REF --name-only)
  for m in "${MAPFILE[@]}"; do
    if [[ $m =~ ^([^/]+)/ ]]; then
      case "${BASH_REMATCH[1]/$'\n'/}" in
        Examples)
          if [[ $m =~ ^Examples/([^/]+)/ ]]; then
            local examples="${BASH_REMATCH[1]/$'\n'/}"
            case "$examples=" in
              $SWIGLANG)
                #echo exit 0
                echo "catch Examples/SWIGLANG $m"
                ;;
              test-suite)
                if [[ $m =~ ^Examples/test-suite/([^/]+)/ ]]; then
                  local test_suite="${BASH_REMATCH[1]/$'\n'/}"
                  case "$test_suite" in
                    $SWIGLANG)
                      #echo exit 0
                      echo "catch Examples/test-suite/SWIGLANG $m"
                      ;;
                    schemerunme)
                      if [[ "$SWIGLANG" = "guile" ]]; then
                        #echo exit 0
                        echo "catch Examples/test-suite/schemerunme <- guile SWIGLANG $m"
                      fi
                      ;;
                    *)
                      islang "$test_suite"
                      if $isLang; then
                        #echo exit 1
                        echo "not my lang Examples/test-suite/*/ $m"
                      else
                        #echo exit 0
                        echo "catch all Examples/test-suite/*/ $m"
                      fi
                      ;;
                  esac # ^Examples/test-suite/*/
                else
                  #echo exit 0
                  echo "catch all Examples/test-suite/* $m"
                fi # # ^Examples/test-suite/*
                ;;
              *)
                islang "$examples"
                if $isLang; then
                  #echo exit 1
                  echo "not my lang Examples/*/ $m"
                else
                  #echo exit 0
                  echo "catch all Examples/*/ $m"
                fi
                ;;
            esac # ^Examples/*/
          else
            #echo exit 0
            echo "catch all Examples/* $m"
          fi # ^Examples/*
          ;;
        Lib)
          if [[ $m =~ ^Lib/([^/]+)/ ]]; then
            local lib="${BASH_REMATCH[1]/$'\n'/}"
            case "$lib" in
              $SWIGLANG)
                #echo exit 0
                echo "catch Lib/SWIGLANG/ $m"
                ;;
              *)
                islang "$lib"
                if $isLang; then
                  #echo exit 1
                  echo "not my lang Lib/*/ $m"
                else
                  #echo exit 0
                  echo "catch all Lib/*/ $m"
                fi
                ;;
            esac # ^Lib/*/
          else
            #echo exit 0
            echo "catch all Lib/* $m"
          fi # ^Lib/*
          ;;
        Source)
          if [[ $m =~ ^Source/Modules/([^.]+).cxx ]]; then
            local source="${BASH_REMATCH[1]/$'\n'/}"
            case "$source" in
              $SWIGLANG)
                #echo exit 0
                echo "catch Source/Modules/SWIGLANG.cxx $m"
                ;;
              tcl8)
                #echo exit 0
                echo "catch Source/Modules/tcl8.cxx $m"
                ;;
              *)
                islang "$source"
                if $isLang; then
                  #echo exit 1
                  echo "not my lang Source/Modules/*.cxx $m"
                else
                  #echo exit 0
                  echo "catch all Source/Modules/*.cxx $m"
                fi
                ;;
            esac # Source/Modules/*.cxx
          else
            #echo exit 0
            echo "catch all Source $m"
          fi # ^Source
          ;;
        Doc)
          if [[ $m =~ ^Doc/Manual/([^.]+).html ]]; then
            l="${BASH_REMATCH[1]/$'\n'/}"
            local doc= "${l,,}"
            case "$doc" in
              $SWIGLANG)
                #echo exit 0
                echo "catch Doc/Manual/SWIGLANG.html $m"
                ;;
              *)
                islang "$doc"
                if $isLang; then
                  #echo exit 1
                  echo "not my lang Doc/Manual/*.html $m"
                else
                  #echo exit 0
                  echo "catch all Doc/Manual/*.html $m"
                fi
                ;;
            esac # Doc/Manual/*.html
          else
            #echo exit 0
            echo "catch all Doc $m"
          fi # ^Source
          ;;
        *)
          #echo exit 0
          echo "catch all */ $m"
          ;;
      esac # ^*/
    else
      #echo exit 0
      echo "catch all * $m"
    fi # ^*
  done
  #echo exit 1
}
echo "$0 Start ======="
main
