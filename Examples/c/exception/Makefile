TOP        = ../..
SWIGEXE    = $(TOP)/../swig
SWIG_LIB_DIR = $(TOP)/../$(TOP_BUILDDIR_TO_TOP_SRCDIR)Lib
CXXSRCS    = example.cxx
TARGET     = example
INTERFACE  = example.i

check_c: build
	$(MAKE) -f $(TOP)/Makefile SRCDIR='$(SRCDIR)' \
	TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' RUNME_EXT=c c_run

check_cxx: build
	$(MAKE) -f $(TOP)/Makefile SRCDIR='$(SRCDIR)' \
	TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' RUNME_EXT=cxx c_run

check: check_c check_cxx

build:
	$(MAKE) -f $(TOP)/Makefile SRCDIR='$(SRCDIR)' CXXSRCS='$(CXXSRCS)' \
	SWIG_LIB_DIR='$(SWIG_LIB_DIR)' SWIGEXE='$(SWIGEXE)' \
	SWIGOPT='$(SWIGOPT)' TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' c_cpp

clean:
	$(MAKE) -f $(TOP)/Makefile SRCDIR='$(SRCDIR)' c_clean
