TOP        = ../..
SWIG       = $(TOP)/../preinst-swig
CXXSRCS    = example.cxx
TARGET     = example
INTERFACE  = example.i
LIBS       = -lm
SWIGOPT    = 

all::
	$(MAKE) -f $(TOP)/Makefile $(SWIGLIB) CXXSRCS='$(CXXSRCS)' SWIG='$(SWIG)' \
	SWIGOPT='$(SWIGOPT)' TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' python_cpp

static::
	$(MAKE) -f $(TOP)/Makefile $(SWIGLIB) CXXSRCS='$(CXXSRCS)' SWIG='$(SWIG)' \
	SWIGOPT='$(SWIGOPT)' TARGET='mypython' INTERFACE='$(INTERFACE)' python_cpp_static

clean::
	$(MAKE) -f $(TOP)/Makefile python_clean
	rm -f $(TARGET).py

check: all
	$(MAKE) -f $(TOP)/Makefile python_run
