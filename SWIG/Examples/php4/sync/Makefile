TOP        = ../..
SWIG       = $(TOP)/../swig
CXXSRCS	   = example.cxx
TARGET     = libexample
INTERFACE  = example.i
SWIGOPT    = -shadow #-nosync

all::
	$(MAKE) -f $(TOP)/Makefile SRCS='$(SRCS)' SWIG='$(SWIG)' \
	SWIGOPT='$(SWIGOPT)' TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' php4_cpp

clean::
	rm -f *_wrap* *.o core *~ *.so *.php php_example.h

check: all
