TOP        = ../..
SWIGEXE    = $(TOP)/../swig
SWIG_LIB_DIR = $(TOP)/../$(TOP_BUILDDIR_TO_TOP_SRCDIR)Lib
CXXSRCS    = example.c
TARGET     = example
INTERFACE  = example.i
SWIGOPT    =
OBJCSRCS   = runme.m
OBJCFLAGS  = -fconstant-string-class=NSConstantString

check: build
	$(MAKE) -f $(TOP)/Makefile SRCDIR='$(SRCDIR)' OBJCSRCS='$(OBJCSRCS)' OBJCFLAGS='$(OBJCFLAGS)' TARGET='$(TARGET)' objc_run

build:
	$(MAKE) -f $(TOP)/Makefile SRCDIR='$(SRCDIR)' CXXSRCS='$(CXXSRCS)' \
	SWIG_LIB_DIR='$(SWIG_LIB_DIR)' SWIGEXE='$(SWIGEXE)' \
	SWIGOPT='$(SWIGOPT)' TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' objc_cpp

clean:
	$(MAKE) -f $(TOP)/Makefile SRCDIR='$(SRCDIR)' TARGET='$(TARGET)' objc_clean
