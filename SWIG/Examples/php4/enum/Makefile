TOP        = ../..
SWIG       = $(TOP)/../swig
CXXSRCS    = example.cxx
TARGET     = libexample
INTERFACE  = example.i
LIBS       = -lm

all::
	$(MAKE) -f $(TOP)/Makefile CXXSRCS='$(CXXSRCS)' SWIG='$(SWIG)' \
	TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' php4_cpp

clean::
	$(MAKE) -f $(TOP)/Makefile php4_clean

check: all
