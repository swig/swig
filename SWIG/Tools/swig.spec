%define ver 1.3a4
%define prefix /usr

# Preamble
Summary: Simplified Wrapper and Interface Generator
Name: swig
Version: %ver
Prefix: %prefix
BuildRoot: /usr/src/redhat/BUILD
Release: 1
Copyright: BSD
URL: http://www.swig.org
Group: System Environment/Daemons
Source0: http://download.sourceforge.net/swig/swig1.3a4.tar.gz
Packager: Dustin Mitchell <dustin@cs.uchicago.edu>
%description
SWIG is an interface compiler that connects programs written in C,
C++, and Objective-C with scripting languages including Perl, Python,
and Tcl/Tk. It works by taking the declarations commonly found in
C/C++ header files and using them to generate the glue code (wrappers)
that scripting languages need to access the underlying C/C++ code

# PREP
%prep
rm -rf $RPM_BUILD_DIR/swig-%{ver}
zcat $RPM_SOURCE_DIR/swig-%{ver}.tar.gz | tar -xvvf -
mv $RPM_BUILD_DIR/SWIG-%{ver} $RPM_BUILD_DIR/swig-%{ver}

# BUILD
%build
cd $RPM_BUILD_DIR/swig-%{ver}
./configure --prefix=%{prefix}
make

# INSTALL
%install
cd $RPM_BUILD_DIR/swig-%{ver}
make prefix=$RPM_BUILD_DIR%{prefix} install

# FILES
%files
%{prefix}/lib/swig1.3/tcl/constarray.i
%{prefix}/lib/swig1.3/tcl/consthash.i
%{prefix}/lib/swig1.3/tcl/ptrlang.i
%{prefix}/lib/swig1.3/tcl/tclsh.i
%{prefix}/lib/swig1.3/tcl/typemaps.i
%{prefix}/lib/swig1.3/tcl/wish.i
%{prefix}/lib/swig1.3/tcl/object.swg
%{prefix}/lib/swig1.3/tcl/swigtcl8.swg
%{prefix}/lib/swig1.3/array.i
%{prefix}/lib/swig1.3/autodoc.i
%{prefix}/lib/swig1.3/carray.i
%{prefix}/lib/swig1.3/constraints.i
%{prefix}/lib/swig1.3/ctype.i
%{prefix}/lib/swig1.3/exception.i
%{prefix}/lib/swig1.3/malloc.i
%{prefix}/lib/swig1.3/math.i
%{prefix}/lib/swig1.3/memory.i
%{prefix}/lib/swig1.3/objc.i
%{prefix}/lib/swig1.3/pointer.i
%{prefix}/lib/swig1.3/stdlib.i
%{prefix}/lib/swig1.3/timers.i
%{prefix}/lib/swig1.3/perl5/perlmain.i
%{prefix}/lib/swig1.3/perl5/ptrlang.i
%{prefix}/lib/swig1.3/perl5/typemaps.i
#%{prefix}/lib/swig1.3/perl5/headers.swg # doesn't seem to exist
%{prefix}/lib/swig1.3/perl5/perl5.swg
#%{prefix}/lib/swig1.3/perl5/perl5mg.swg # doesn't seem to exist
%{prefix}/lib/swig1.3/perl5/Makefile.pl
%{prefix}/lib/swig1.3/python/embed.i
%{prefix}/lib/swig1.3/python/embed13.i
%{prefix}/lib/swig1.3/python/embed14.i
%{prefix}/lib/swig1.3/python/embed15.i
%{prefix}/lib/swig1.3/python/ptrlang.i
%{prefix}/lib/swig1.3/python/typemaps.i
%{prefix}/lib/swig1.3/python/typemaps_old.i
%{prefix}/lib/swig1.3/python/defarg.swg
%{prefix}/lib/swig1.3/python/python.swg
%{prefix}/lib/swig1.3/guile/guilemain.i
%{prefix}/lib/swig1.3/guile/interpreter.i
%{prefix}/lib/swig1.3/guile/typemaps.i
%{prefix}/lib/swig1.3/guile/guile.swg
%{prefix}/lib/swig1.3/guile/guiledec.swg
%{prefix}/lib/swig1.3/java/typemaps.i
%{prefix}/lib/swig1.3/java/java.swg
%{prefix}/lib/swig1.3/mzscheme/typemaps.i
%{prefix}/lib/swig1.3/mzscheme/mzscheme.swg
%{prefix}/bin/swig
