TOP        = ../..
SWIG       = $(TOP)/../swig
CXXSRCS    = example.cxx
TARGET     = examplec
INTERFACE  = example.i
LIBS       = -lm
SWIGOPT    = -shadow

all::
	$(MAKE) -f $(TOP)/Makefile CXXSRCS='$(CXXSRCS)' SWIG='$(SWIG)' \
	SWIGOPT='$(SWIGOPT)' TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' python_cpp

static::
	$(MAKE) -f $(TOP)/Makefile CXXSRCS='$(CXXSRCS)' SWIG='$(SWIG)' \
	SWIGOPT='$(SWIGOPT)' TARGET='mypython' INTERFACE='$(INTERFACE)' python_cpp_static

clean::
	$(MAKE) -f $(TOP)/Makefile python_clean

check: all
