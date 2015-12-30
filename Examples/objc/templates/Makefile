TOP        = ../..
SWIGEXE    = $(TOP)/../swig
SWIG_LIB_DIR = $(TOP)/../$(TOP_BUILDDIR_TO_TOP_SRCDIR)Lib
TARGET     = example
INTERFACE  = example.i
OBJCSRCS   = runme.m
OBJCFLAGS  = -fconstant-string-class=NSConstantString 

all::
	$(MAKE) -f $(TOP)/Makefile SRCDIR='$(SRCDIR)' CXXSRCS='$(CXXSRCS)' \
	SWIG_LIB_DIR='$(SWIG_LIB_DIR)' SWIGEXE='$(SWIGEXE)' \
	TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' objc_cpp
	
clean::
	$(MAKE) -f $(TOP)/Makefile SRCDIR='$(SRCDIR)' objc_clean

check:: all
	$(MAKE) -f $(TOP)/Makefile SRCDIR='$(SRCDIR)' OBJCSRCS='$(OBJCSRCS)' OBJCFLAGS='$(OBJCFLAGS)' TARGET='$(TARGET)' objc_run


