TOP        = ../..
SWIG       = $(TOP)/../swig
CXXSRCS	   = example.cxx
TARGET     = libexample
INTERFACE  = example.i
SWIGOPT    = -noproxy

all::
	$(MAKE) -f $(TOP)/Makefile CXXSRCS='$(CXXSRCS)' SWIG='$(SWIG)' \
	SWIGOPT='$(SWIGOPT)' TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' php4_cpp

clean::
	rm -f *_wrap* *.o core *~ *.so *.php php_example.h

check: all
