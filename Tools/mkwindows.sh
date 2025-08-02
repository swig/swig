#!/bin/bash

# path to zip program
zip=

wine=

bits="64"

# options for configure
extraconfigureoptions=
compileflags="-O2 -Wall -Wextra"

usage()
{
    cat <<EOF
Usage: $0 [--bits BITS] [--help] [--zip ZIP] version
Positional arguments:
  version     	  version string for input tarball and output zip file,
                  in format x.y.z, for example 4.1.0 or 4.1.0-beta1
Options:
  -b, --bits BITS Compile for 32-bit or 64-bit architecture,
                  BITS must be one of 32 or 64, default is 64
  -h, --help      Show this help
  -z, --zip ZIP   ZIP should contain the path to zip executable, default
		  is /c/cygwin/bin/zip on MinGW, zip on Linux and Cygwin

$0 builds the SWIG Windows distribution (swigwin-x.y.z.zip) from a source
tarball (swig-x.y.x.tar.gz)

Requires running in either:
- MinGW environment
- Linux using MinGW cross compiler
- Cygwin using MinGW compiler
EOF
}

echo_error_exit()
{
  echo "$@" >&2
  exit 1
}

while [[ $# -gt 0 ]]; do
  case $1 in
    -h|--help)
      usage
      exit 0
      ;;
    -b|--bits)
      shift
      bits="$1"
      ;;
    -z|--zip)
      shift
      zip="$1"
      ;;
    -*|--*)
      echo_error_exit "Unknown option $1"
      ;;
    *)
      version="$1"
      ;;
  esac
  shift
done

if [ -z "$version" ]; then
  usage
  exit 1
fi

echo "Creating swigwin-$version.zip SWIG Windows distribution ($bits-bits binary)..."

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
      wine=$(which wine)
    fi
    if test x$wine = x; then
      echo_error_exit "Could not detect wine - please install wine-stable package."
    fi
    if [ "$bits" = "32" ]; then
      echo "Checking that mingw 32-bit gcc is installed/available"
      if test -n "`which i686-w64-mingw32-gcc`" ; then
        i686-w64-mingw32-gcc --version || exit 1
        i686-w64-mingw32-g++ --version || exit 1
        extraconfigureoptions="--host=i686-w64-mingw32 --build=i686-linux"
        # Statically link so that libstdc++-6.dll and libgcc_s_sjlj-1.dll don't have to be shipped
        compileflags="$compileflags -static-libgcc -static-libstdc++"
      elif test -n "`which i586-mingw32msvc-gcc`" ; then
        i586-mingw32msvc-gcc --version || exit 1
        i586-mingw32msvc-g++ --version || exit 1
        extraconfigureoptions="--host=i586-mingw32msvc --build=i686-linux"
      else
        echo_error_exit "Could not detect mingw gcc - please install mingw-w64 package."
      fi
    elif [ "$bits" = "64" ]; then
      echo "Checking that mingw 64-bit gcc is installed/available"
      if test -n "`which x86_64-w64-mingw32-gcc`" ; then
        x86_64-w64-mingw32-gcc --version || exit 1
        x86_64-w64-mingw32-g++ --version || exit 1
        extraconfigureoptions="--host=x86_64-w64-mingw32 --build=x86_64-linux"
        # Statically link so that libstdc++-6.dll and libgcc_s_sjlj-1.dll don't have to be shipped
        compileflags="$compileflags -m64 -static-libgcc -static-libstdc++"
      else
        echo_error_exit "Could not detect mingw gcc - please install mingw-w64 package."
      fi
    else
      echo_error_exit "Invalid value for bits:$bits."
    fi
  else 
    if test "$cygwin"; then
      echo "Building native Windows executable on Cygwin"
      if test x$zip = x; then
        zip=zip
      fi
      compileflags="$compileflags -mno-cygwin"
    else
      echo_error_exit "Unknown platform. Requires either Linux or MinGW."
    fi
  fi
fi

export CFLAGS="$compileflags"
export CXXFLAGS="$compileflags"

swigbasename=swig-$version
swigwinbasename=swigwin-$version
tarball=$swigbasename.tar.gz
pcre_tarball=`ls pcre2-*.tar.*`

if ! test -f "$pcre_tarball"; then
  echo_error_exit "Could not find PCRE2 tarball. Please download a PCRE2 source tarball from https://www.pcre.org and place in the same directory as the SWIG tarball."
fi

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
      (cd ../.. && cp $pcre_tarball $builddir/$swigbasename)
      echo Running: Tools/pcre-build.sh $extraconfigureoptions
      ./Tools/pcre-build.sh $extraconfigureoptions
      echo Running: ./configure $extraconfigureoptions --without-alllang
      ./configure $extraconfigureoptions --without-alllang
      echo "Compiling (quietly)..."
      make > build.log
      echo "Simple check to see if swig.exe runs and show versions..."
      env LD_LIBRARY_PATH= PATH= $wine ./swig.exe -version || exit 1
      env LD_LIBRARY_PATH= PATH= $wine ./swig.exe -pcreversion || exit 1
      echo "Simple check to see if ccache-swig.exe runs..."
      env LD_LIBRARY_PATH= PATH= $wine ./CCache/ccache-swig.exe -V || exit 1
      echo "Creating $swigwinbasename.zip..."
      cd ..
      cp $swigbasename/swig.exe $swigwinbasename
      cp $swigbasename/CCache/ccache-swig.exe $swigwinbasename/CCache
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
      echo_error_exit "Expecting tarball to create directory: $swigbasename but it does not exist"
    fi
else
  echo_error_exit "tarball missing: $tarball"
fi

exit 0
