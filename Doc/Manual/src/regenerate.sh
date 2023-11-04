#!/bin/sh -ev

PYTHON=python3

# Convert markdown to standalone HTML
pandoc --from=gfm+smart --no-highlight \
  -M title:"SWIG and Fortran" -M author:"Seth R Johnson" \
  --wrap=none \
  --toc --standalone -H style.css -o ../Fortran.html Fortran.md
# Transform Pandoc formatting to SWIG manual-style formatting
$PYTHON pandoc2swigman.py
# Generate table of contents (and update top-level TOC)
(cd .. && $PYTHON maketoc.py)
