TOP        = ../..
SWIG       = $(TOP)/../preinst-swig
CXXSRCS    = example.cxx
TARGET     = example
INTERFACE  = example.i
LIBS       =
SWIGOPT    = -noproxy

all::
	$(MAKE) -f $(TOP)/Makefile CXXSRCS='$(CXXSRCS)' SWIG='$(SWIG)' \
	SWIGOPT='$(SWIGOPT)' TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' \
	php4_cpp

static::
	$(MAKE) -f $(TOP)/Makefile CXXSRCS='$(CXXSRCS)' SWIG='$(SWIG)' \
	SWIGOPT='$(SWIGOPT)' TARGET='myphp4' INTERFACE='$(INTERFACE)' \
	php4_cpp_static

clean::
	$(MAKE) -f $(TOP)/Makefile php4_clean
	rm -f $(TARGET).php

check: all
	$(MAKE) -f $(TOP)/Makefile php4_run
