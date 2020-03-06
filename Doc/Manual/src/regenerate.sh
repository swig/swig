#!/bin/sh -ev

pandoc --from=gfm+smart --no-highlight \
  -M title:"SWIG and Fortran" -M author:"Seth R Johnson" \
  --toc --standalone -H style.css -o ../Fortran.html Fortran.md
python pandoc2swigman.py
(cd .. && python maketoc.py)
