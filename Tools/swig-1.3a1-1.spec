# Preamble
Summary: Simplified Wrapper and Interface Generator
Name: swig
Version: 1.3a3
Release: 1
Copyright: BSD
URL: http://www.swig.org
Group: System Environment/Daemons
Source0: http://download.sourceforge.net/swig/swig1.3a3.tar.gz
Packager: Dustin Mitchell <dustin@cs.uchicago.edu>
%description
SWIG is an interface compiler that connects programs written in C,
C++, and Objective-C with scripting languages including Perl, Python,
and Tcl/Tk. It works by taking the declarations commonly found in
C/C++ header files and using them to generate the glue code (wrappers)
that scripting languages need to access the underlying C/C++ code

# PREP
%prep
rm -rf $RPM_BUILD_DIR/swig1.3a3
zcat $RPM_SOURCE_DIR/swig1.3a3.tar.gz | tar -xvvf -
mv $RPM_BUILD_DIR/SWIG1.3a3 $RPM_BUILD_DIR/swig1.3a3

# BUILD
%build
cd $RPM_BUILD_DIR/swig1.3a3
./configure --prefix=/usr
make

# INSTALL
%install
cd $RPM_BUILD_DIR/swig1.3a3
make install

# FILES
%files
/usr/lib/swig1.3/tcl/constarray.i
/usr/lib/swig1.3/tcl/consthash.i
/usr/lib/swig1.3/tcl/ptrlang.i
/usr/lib/swig1.3/tcl/tclsh.i
/usr/lib/swig1.3/tcl/typemaps.i
/usr/lib/swig1.3/tcl/wish.i
/usr/lib/swig1.3/tcl/object.swg
/usr/lib/swig1.3/tcl/swigtcl8.swg
/usr/lib/swig1.3/array.i
/usr/lib/swig1.3/autodoc.i
/usr/lib/swig1.3/carray.i
/usr/lib/swig1.3/constraints.i
/usr/lib/swig1.3/ctype.i
/usr/lib/swig1.3/exception.i
/usr/lib/swig1.3/malloc.i
/usr/lib/swig1.3/math.i
/usr/lib/swig1.3/memory.i
/usr/lib/swig1.3/objc.i
/usr/lib/swig1.3/pointer.i
/usr/lib/swig1.3/stdlib.i
/usr/lib/swig1.3/timers.i
/usr/lib/swig1.3/perl5/perlmain.i
/usr/lib/swig1.3/perl5/ptrlang.i
/usr/lib/swig1.3/perl5/typemaps.i
/usr/lib/swig1.3/perl5/headers.swg
/usr/lib/swig1.3/perl5/perl5.swg
/usr/lib/swig1.3/perl5/perl5mg.swg
/usr/lib/swig1.3/perl5/Makefile.pl
/usr/lib/swig1.3/python/embed.i
/usr/lib/swig1.3/python/embed13.i
/usr/lib/swig1.3/python/embed14.i
/usr/lib/swig1.3/python/embed15.i
/usr/lib/swig1.3/python/ptrlang.i
/usr/lib/swig1.3/python/typemaps.i
/usr/lib/swig1.3/python/typemaps_old.i
/usr/lib/swig1.3/python/defarg.swg
/usr/lib/swig1.3/python/python.swg
/usr/lib/swig1.3/guile/guilemain.i
/usr/lib/swig1.3/guile/interpreter.i
/usr/lib/swig1.3/guile/typemaps.i
/usr/lib/swig1.3/guile/guile.swg
/usr/lib/swig1.3/guile/guiledec.swg
/usr/lib/swig1.3/java/typemaps.i
/usr/lib/swig1.3/java/java.swg
/usr/lib/swig1.3/mzscheme/typemaps.i
/usr/lib/swig1.3/mzscheme/mzscheme.swg
/usr/bin/swig
