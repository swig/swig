TOP        = ../..
SWIG       = $(TOP)/../preinst-swig
CXXSRCS    =
TARGET     = example
INTERFACE  = example.i
LIBS       = -lm
SWIGOPT    =

check: build
	$(MAKE) -f $(TOP)/Makefile SRCDIR='$(SRCDIR)' lua_run

build:
	$(MAKE) -f $(TOP)/Makefile SRCDIR='$(SRCDIR)' CXXSRCS='$(CXXSRCS)' SWIG='$(SWIG)' \
	SWIGOPT='$(SWIGOPT)' TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' lua_cpp

static:
	$(MAKE) -f $(TOP)/Makefile SRCDIR='$(SRCDIR)' CXXSRCS='$(CXXSRCS)' SWIG='$(SWIG)' \
	TARGET='mylua' INTERFACE='$(INTERFACE)' lua_cpp_static

clean:
	$(MAKE) -f $(TOP)/Makefile SRCDIR='$(SRCDIR)' lua_clean
