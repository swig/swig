#!/bin/sh

# Build Windows distribution (swigwin-1.3.x.zip) -- requires running in a MinGW environment or on Linux using MinGW cross compiler

# path to zip program
zip=

# special options for configure
configureoptions=

if test x$1 != x; then
    version=$1
    if test x$2 != x; then
        zip=$2;
        echo zip: $zip;
    fi
else
    echo "Usage: mkwindows.sh version [zip]"
    echo "       version should be 1.3.x"
    echo "       zip is full path to zip program - default is /c/cygwin/bin/zip on MinGW, zip on Linux"
    exit 1
fi

uname=`uname -a`
mingw=`echo "$uname" | grep -i mingw`
linux=`echo "$uname" | grep -i linux`
if test "$mingw"; then
  echo "Building on MinGW";
  zip=/c/cygwin/bin/zip
else 
  if test "$linux"; then
    echo "Building on Linux"
    if test x$zip = x; then
      zip=zip
      configureoptions="--host=i586-mingw32msvc --build=i686-linux"
    fi
  else 
    echo "Unknown platform. Requires either Linux or MinGW."
    exit 1;
  fi
fi

swigbasename=swig-$version
swigwinbasename=swigwin-$version
tarball=$swigbasename.tar.gz

if test -f "$tarball"; then
    builddir=build-$version
    if test -e $builddir; then
      echo "Deleting directory $builddir..."
      rm -rf $builddir
    fi
    echo "Creating directory $builddir..."
    mkdir $builddir
    cd $builddir
    echo "Unzipping tarball..."
    tar -zxf ../$tarball
    sleep 2 # fix strange not finding newly created directory
    if test -d $swigbasename; then
      mv $swigbasename $swigwinbasename
      tar -zxf ../$tarball
      confoptions="$configureoptions CXXFLAGS=-O2 CFLAGS=-O2"
      echo Running configure $confoptions
      cd $swigbasename
      ./configure $confoptions
      echo "Compiling (quietly)..."
      make > build.log
      echo "Simple check to see if swig.exe runs..."
      ./swig.exe -version
      echo "Creating $swigwinbasename.zip..."
      cd ..
      cp $swigbasename/swig.exe $swigwinbasename
      cp $swigbasename/Lib/swigwarn.swg $swigwinbasename/Lib
      sleep 2 # fix strange not finding swig.exe
      echo "Unzip into a directory of your choice. Please read the README file as well as Doc\Manual\Windows.html for installation instructions." > swig_windows_zip_comments.txt
      rm -f ../$swigwinbasename.zip
      $zip -q -r -9 -z < swig_windows_zip_comments.txt ../$swigwinbasename.zip $swigwinbasename
      rm -f swig_windows_zip_comments.txt
      echo "Cleaning up..."
      cd ..
      rm -rf $builddir
      echo "Finished building $swigwinbasename.zip"
    else
      echo "Expecting tarball to create directory: $swigbasename but it does not exist"
      exit 1
    fi
else
    echo tarball missing: $tarball 
    exit 1
fi

exit 0
