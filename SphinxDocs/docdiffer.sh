#!/bin/bash

# Tool to help diff the old and new documentation.
# Old documentation is in Doc/Manual/*.html
# New documentation is in SphinxDocs/source/Manual/*.rst

# Before running install appropriate tools:
# sudo apt install pandoc python3-docutils html2text

set -e

usage() {
  echo "Tool to help diff the old and new documentation:"
  echo "Usage:"
  echo "  $0 [-d=<toolname>] | [-n] <name>"
  echo "  -n             do not run a difftool"
  echo "  -d=<toolname>  set difftool name to <toolname>, default is diff"
  echo "  <name>         the basename of a documentation file, such as 'Java'"
  exit 1
}

difftool=diff

for i in "$@"
do
  case $i in
    --no-diff|-n)
      difftool=""
      shift
      ;;
    --difftool=*|-d=*)
      difftool="${i#*=*}"
      shift
      ;;
    -*)
      usage
      ;;
    *)
      file=$i
      shift
      ;;
  esac
done

if [[ -z "$file" ]] ; then
  usage
fi

# Remove chapter numbering in old html file
cp ../Doc/Manual/$file.html /tmp/$file-old.html
python ../Doc/Manual/makechap-no-numbering.py /tmp/$file-old.html 0 > /dev/null

# Did not use html2text --body-width=0 as not available in Ubuntu's html2text
# https://github.com/aaronsw/html2text probably should be used
html2text /tmp/$file-old.html > /tmp/$file-old.txt 
rst2html.py ../SphinxDocs/source/Manual/$file.rst > /tmp/$file-new.html

# The sed below removes one * in headings.
# Done because the original html headings are one more than in the original than the new html.
# For example, H2 is used in original html and H1 is used in new html.
# H1 generates one more * after converted to text.
cat /tmp/$file-new.html | html2text | sed -e 's/^\*\*\*\(.*\)\*\*\*$/**\1**/' > /tmp/$file-new.txt

if [[ -z "$difftool" ]] ; then
  echo "Now run a diff tool such as:"
  echo "diff /tmp/$file-old.txt /tmp/$file-new.txt"
else
  echo "Running: $difftool /tmp/$file-old.txt /tmp/$file-new.txt"
  $difftool /tmp/$file-old.txt /tmp/$file-new.txt
fi

