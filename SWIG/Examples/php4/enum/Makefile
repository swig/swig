TOP        = ../..
SWIG       = $(TOP)/../swig
CXXSRCS    = example.cxx
TARGET     = libexample
INTERFACE  = example.i
LIBS       = -lm
SWIGOPT    = -noproxy

all::
	$(MAKE) -f $(TOP)/Makefile CXXSRCS='$(CXXSRCS)' SWIG='$(SWIG)' \
	TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' php4_cpp

clean::
	rm -f *_wrap* *.o core *~ *.so *.php

check: all
