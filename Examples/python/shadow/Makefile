TOP        = ../..
SWIG       = $(TOP)/../swig -shadow
CXXSRCS    = example.cxx
TARGET     = examplec
INTERFACE  = example.i
LIBS       = -lm

all::
	$(MAKE) -f $(TOP)/Makefile CXXSRCS='$(CXXSRCS)' SWIG='$(SWIG)' \
	TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' python_cpp

static::
	$(MAKE) -f $(TOP)/Makefile CXXSRCS='$(CXXSRCS)' SWIG='$(SWIG)' \
	TARGET='mypython' INTERFACE='$(INTERFACE)' python_cpp_static

clean::
	rm -f *_wrap* *.o *~ *.so mypython *.pyc .~* core

check: all
