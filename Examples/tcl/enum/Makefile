TOP        = ../..
SWIG       = $(TOP)/../swig
CXXSRCS    = example.cxx
TARGET     = example
INTERFACE  = example.i
LIBS       = -lm

all::
	$(MAKE) -f $(TOP)/Makefile CXXSRCS='$(CXXSRCS)' SWIG='$(SWIG)' \
	TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' tcl_cpp

static::
	$(MAKE) -f $(TOP)/Makefile CXXSRCS='$(CXXSRCS)' SWIG='$(SWIG)' \
	TARGET='mytclsh' INTERFACE='$(INTERFACE)' tclsh_cpp_static

clean::
	rm -f *_wrap* *.o *~ *.so mytclsh *.pyc .~* core

check: all
