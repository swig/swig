#! /bin/sh

# Bootstrap the development environment - add extra files needed to run configure. 
# Note autoreconf should do what this file achieves, but it has a bug when working with automake!
# The latest config.guess and config.sub should be copied into Tools/config and checked into CVS
# when upgrading the autotools. Otherwise this script will ensure the latest is copied from 
# your autotool installation.

set -x
test -d Tools/config || mkdir Tools/config
aclocal -I Tools/config
autoheader

# Note: on Mac OS X there is a different program 'libtoolize' that is definitely not
# what we want to run.  Instead, we want to use 'glibtoolize'

if test -x /usr/bin/glibtoolize; then
   glibtoolize --force --copy
else
   libtoolize --force --copy
fi
automake --add-missing --copy --force-missing
autoconf
