#!/bin/sh
#
# Build run-time libraries for SWIG.  This script will attempt to build libraries
# for all of SWIG's target languages, but may report failures for uninstalled 
# packages.
#     

necho() {
   if [ "`echo -n`" = "-n" ]; then
      echo "${@}\c"
   else
      echo -n "${@}"
   fi
}

# Script that attempts to produce different run-time libraries

TARGET='perl5 python tcl ruby'

echo "Building the SWIG runtime libraries."
echo ""
echo "The runtime libraries are only needed if you are building"
echo "multiple extension modules that need to share information."
echo ""
echo "*** Note ***"
echo "Some of these builds may fail due to uninstalled packages."
echo "If a build fails and you want to know what is wrong, do"
echo "a manual build by going into the Runtime directory and"
echo "typing 'make target' where target is the name of the target"
echo "that is failing."
echo ""

for i in ${TARGET}; do 
necho "    Building ${i}"; 
if make ${i} >/dev/null 2>&1; then 
# See if SWIG generated any errors at all
	echo " ....... OK.";
else 
    echo " ....... failed.";
fi;
done

