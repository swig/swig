TOP        = ../..
SWIG       = $(TOP)/../swig
CXXSRCS    = example.c
TARGET     = example
INTERFACE  = example.i
SWIGOPT    = 
all::
	$(MAKE) -f $(TOP)/Makefile CXXSRCS='$(CXXSRCS)' SWIG='$(SWIG)' \
	SWIGOPT='$(SWIGOPT)' TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' perl5_cpp

static::
	$(MAKE) -f $(TOP)/Makefile CXXSRCS='$(CXXSRCS)' SWIG='$(SWIG)' \
	SWIGOPT='$(SWIGOPT)' TARGET='myperl' INTERFACE='$(INTERFACE)' perl5_cpp_static

clean::
	rm -f *_wrap* *.o core *~ *.so *.pm myperl

check: all
