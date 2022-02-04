TOP        = ../..
SWIGEXE    = $(TOP)/../swig
SWIG_LIB_DIR = $(TOP)/../$(TOP_BUILDDIR_TO_TOP_SRCDIR)Lib
CXXSRCS    = 
TARGET     = example
INTERFACE  = example.i
INTERFACE2 = downstream.i
DOWNSTREAM2 = downstream
SWIGOPT    =
FORTRANSRCS = runme.f90

check: build
	$(MAKE) -f $(TOP)/Makefile SRCDIR='$(SRCDIR)' fortran_run

build:
	$(MAKE) -f $(TOP)/Makefile SRCDIR='$(SRCDIR)' CXXSRCS='$(CXXSRCS)' \
	  SWIG_LIB_DIR='$(SWIG_LIB_DIR)' SWIGEXE='$(SWIGEXE)' \
	  SWIGOPT='$(SWIGOPT)' TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' fortran_cpp
	$(MAKE) -f $(TOP)/Makefile SRCDIR='$(SRCDIR)' \
	  SWIG_LIB_DIR='$(SWIG_LIB_DIR)' SWIGEXE='$(SWIGEXE)' \
	  SWIGOPT='$(SWIGOPT)' TARGET='$(DOWNSTREAM2)' INTERFACE='$(INTERFACE2)' \
	  LIBS='$$(FORTRANLIBPREFIX)$(TARGET)$$(FORTRAN_SO)' \
	  fortran_cpp
	$(MAKE) -f $(TOP)/Makefile TARGET='$(TARGET) $(DOWNSTREAM2)' SRCDIR='$(SRCDIR)' \
		FORTRANSRCS='$(FORTRANSRCS)' fortran_compile

clean:
	$(MAKE) -f $(TOP)/Makefile SRCDIR='$(SRCDIR)' fortran_clean
