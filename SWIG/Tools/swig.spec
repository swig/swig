%define ver          1.3.7
%define rel          1
%define prefix       /usr
%define home_page    http://swig.sourceforge.net/
%define docprefix    %{prefix}/share

######################################################################
# Usually, nothing needs to be changed below here between releases
######################################################################
Summary: Simplified Wrapper and Interface Generator
Name: swig
Version: %{ver}
Release: %{rel}
URL: %{home_page}
Source0: %{name}-%{version}.tar.gz
License: BSD
Group: Development/Tools
BuildRoot: %{_tmppath}/%{name}-root

%description
SWIG is an interface compiler that connects programs written in C,
C++, and Objective-C with scripting languages including Perl, Python,
and Tcl/Tk. It works by taking the declarations commonly found in
C/C++ header files and using them to generate the glue code (wrappers)
that scripting languages need to access the underlying C/C++ code

%prep
%setup -q -n SWIG-%{version}

%build
%configure
make

%install
rm -rf ${RPM_BUILD_ROOT}
# Why is exec_prefix not used in BIN_DIR in Makefile?
%makeinstall BIN_DIR=${RPM_BUILD_ROOT}%{_exec_prefix}/bin
#make install prefix=${RPM_BUILD_ROOT}%{_prefix}
DIR=${RPM_BUILD_ROOT}
find $DIR -type f | sed -e "s#^${RPM_BUILD_ROOT}##g" > %{name}.files
#cp %{name}.files %{_topdir}

%clean
rm -rf ${RPM_BUILD_ROOT}

%files -f %{name}.files
%doc Examples
%doc Doc
%defattr(-,root,root)


%changelog
* Mon Sep 10 2001 Tony Seward <anthony.seward@ieee.org>
- Merge Red Hat's and Dustin Mitchell's .spec files.
- Install all of the examples in the documantation directory.
- Auto create the list of installed files.
