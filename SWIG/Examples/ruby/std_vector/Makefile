TOP        = ../..
SWIG       = $(TOP)/../swig
CXXSRCS    = 
TARGET     = example
INTERFACE  = example.i
LIBS       = -lm
SWIGOPT    = 

all::
	$(MAKE) -f $(TOP)/Makefile CXXSRCS='$(CXXSRCS)' SWIG='$(SWIG)' \
	SWIGOPT='$(SWIGOPT)' TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' ruby_cpp

static::
	$(MAKE) -f $(TOP)/Makefile CXXSRCS='$(CXXSRCS)' SWIG='$(SWIG)' \
	SWIGOPT='$(SWIGOPT)' TARGET='myruby' INTERFACE='$(INTERFACE)' ruby_cpp_static

clean::
	@rm -f example_wrap.cxx example_wrap.o example.so

check: all
