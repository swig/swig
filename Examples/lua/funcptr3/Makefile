TOP        = ../..
SWIG       = $(TOP)/../preinst-swig
CXXSRCS    = example.c
TARGET     = example
INTERFACE  = example.i
LIBS       = 

all::
	$(MAKE) -f $(TOP)/Makefile CXXSRCS='$(CXXSRCS)' SWIG='$(SWIG)' \
	TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' lua

static::
	$(MAKE) -f $(TOP)/Makefile CXXSRCS='$(CXXSRCS)' SWIG='$(SWIG)' \
	TARGET='mylua' INTERFACE='$(INTERFACE)' lua_static

clean::
	$(MAKE) -f $(TOP)/Makefile lua_clean

check: all
