TOP        = ../..
SWIG       = $(TOP)/../preinst-swig
CXXSRCS    = 
TARGET     = example
INTERFACE  = example.i
LIBS       = 

check: build
	$(MAKE) -f $(TOP)/Makefile lua_run

build:
	$(MAKE) -f $(TOP)/Makefile CXXSRCS='$(CXXSRCS)' SWIG='$(SWIG)' \
	TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' lua

static:
	$(MAKE) -f $(TOP)/Makefile CXXSRCS='$(CXXSRCS)' SWIG='$(SWIG)' \
	TARGET='mylua' INTERFACE='$(INTERFACE)' lua_static

clean:
	$(MAKE) -f $(TOP)/Makefile lua_clean
