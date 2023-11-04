TOP        = ../..
SWIGEXE    = $(TOP)/../swig
SWIG_LIB_DIR = $(TOP)/../$(TOP_BUILDDIR_TO_TOP_SRCDIR)Lib
SRCS       = example.c
TARGET     = example
INTERFACE  = example.i
SWIGOPT    =
FORTRANSRCS = runme.f90

check: build
	$(MAKE) -f $(TOP)/Makefile SRCDIR='$(SRCDIR)' fortran_run

build:
	$(MAKE) -f $(TOP)/Makefile SRCDIR='$(SRCDIR)' SRCS='$(SRCS)' \
	  SWIG_LIB_DIR='$(SWIG_LIB_DIR)' SWIGEXE='$(SWIGEXE)' \
	  SWIGOPT='$(SWIGOPT)' TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' fortran
	$(MAKE) -f $(TOP)/Makefile TARGET='$(TARGET)' SRCDIR='$(SRCDIR)' \
		FORTRANSRCS='$(FORTRANSRCS)' fortran_compile

clean:
	$(MAKE) -f $(TOP)/Makefile SRCDIR='$(SRCDIR)' fortran_clean
