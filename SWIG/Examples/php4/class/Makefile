TOP        = ../..
SWIG       = $(TOP)/../swig
CXXSRCS    = example.cxx
TARGET     = example
INTERFACE  = example.i
LIBS       = -lm

all::
	$(MAKE) -f $(TOP)/Makefile CXXSRCS='$(CXXSRCS)' SWIG='$(SWIG)' \
	TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' php4_cpp

clean::
	rm -f *_wrap* *.o *~ *.so  .~* core

check: all
