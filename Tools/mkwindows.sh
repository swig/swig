#!/bin/sh

# Build Windows distribution (swigwin-1.3.x.zip) -- requires running in either:
# - MinGW environment
# - Linux using MinGW cross compiler
# - Cygwin using MinGW compiler

# path to zip program
zip=

# options for configure
extraconfigureoptions=
compileflags="-O2"
extracompileflags=

if test x$1 != x; then
    version=$1
    if test x$2 != x; then
        zip=$2;
        echo zip: $zip;
    fi
else
    echo "Usage: mkwindows.sh version [zip]"
    echo "       Build Windows distribution. Works on Cygwin, MinGW or Linux"
    echo "       version should be 1.3.x"
    echo "       zip is full path to zip program - default is /c/cygwin/bin/zip on MinGW, zip on Linux and Cygwin"
    exit 1
fi

uname=`uname -a`
mingw=`echo "$uname" | grep -i mingw`
linux=`echo "$uname" | grep -i linux`
cygwin=`echo "$uname" | grep -i cygwin`
if test "$mingw"; then
  echo "Building native Windows executable on MinGW";
  if test x$zip = x; then
    zip=/c/cygwin/bin/zip
  fi
else 
  if test "$linux"; then
    echo "Building native Windows executable on Linux"
    if test x$zip = x; then
      zip=zip
    fi
    extraconfigureoptions="--host=i586-mingw32msvc --build=i686-linux CXXFLAGS=-O2 CFLAGS=-O2"
  else 
    if test "$cygwin"; then
      echo "Building native Windows executable on Cygwin"
      if test x$zip = x; then
        zip=zip
      fi
      compileflags="-O2 -mno-cygwin"
    else
      echo "Unknown platform. Requires either Linux or MinGW."
      exit 1;
    fi
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
      cd $swigbasename
      echo Running: ./configure $extraconfigureoptions CFLAGS="$compileflags" CXXFLAGS="$compileflags"
      ./configure $extraconfigureoptions CFLAGS="$compileflags" CXXFLAGS="$compileflags"
      echo "Compiling (quietly)..."
      make > build.log
      echo "Simple check to see if swig.exe runs..."
      env LD_LIBRARY_PATH= PATH= ./swig.exe -version
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
