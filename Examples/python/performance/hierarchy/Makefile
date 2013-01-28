TOP        = ../../..
SWIG       = $(TOP)/../preinst-swig
CXXSRCS       =
TARGET     = Simple
INTERFACE  = Simple.i

default : all

all :
	$(MAKE) -f $(TOP)/Makefile CXXSRCS='$(CXXSRCS)' SWIG='$(SWIG) -module Simple_baseline' \
	TARGET='$(TARGET)_baseline' INTERFACE='$(INTERFACE)' python_cpp
	$(MAKE) -f $(TOP)/Makefile CXXSRCS='$(CXXSRCS)' SWIG='$(SWIG) -O -module Simple_optimized' \
	TARGET='$(TARGET)_optimized' INTERFACE='$(INTERFACE)' python_cpp
	$(MAKE) -f $(TOP)/Makefile CXXSRCS='$(CXXSRCS)' SWIG='$(SWIG) -builtin -O -module Simple_builtin' \
	TARGET='$(TARGET)_builtin' INTERFACE='$(INTERFACE)' python_cpp

static :
	$(MAKE) -f $(TOP)/Makefile CXXSRCS='$(CXXSRCS)' SWIG='$(SWIG)' \
	TARGET='mypython' INTERFACE='$(INTERFACE)' python_cpp_static

clean :
	$(MAKE) -f $(TOP)/Makefile python_clean
	rm -f $(TARGET).py
