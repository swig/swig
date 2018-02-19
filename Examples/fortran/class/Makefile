# Note: this makefile, like those in the other examples, requires that you have
# an in-source-tree build.


TOP        = ../..
SWIGEXE    = $(TOP)/../swig
SWIG_LIB_DIR = $(TOP)/../$(TOP_BUILDDIR_TO_TOP_SRCDIR)Lib
CXXSRCS    = example.cc
TARGET     = example
INTERFACE  = example.i
SWIGOPT    =
FORTRANSRCS = runme.f90
FORTRANFLAGS= -nologo -debug+ -out:runme.exe

check: build
	$(MAKE) -f $(TOP)/Makefile SRCDIR='$(SRCDIR)' fortran_run

build:
	$(MAKE) -f $(TOP)/Makefile SRCDIR='$(SRCDIR)' CXXSRCS='$(CXXSRCS)' \
	SWIG_LIB_DIR='$(SWIG_LIB_DIR)' SWIGEXE='$(SWIGEXE)' \
	SWIGOPT='$(SWIGOPT)' TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' fortran_cpp
	$(MAKE) -f $(TOP)/Makefile SRCDIR='$(SRCDIR)' FORTRANSRCS='$(FORTRANSRCS)' FORTRANFLAGS='$(FORTRANFLAGS)' fortran_compile

clean:
	$(MAKE) -f $(TOP)/Makefile SRCDIR='$(SRCDIR)' fortran_clean
