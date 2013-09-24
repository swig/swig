TOP        = ../..
SWIG       = $(TOP)/../preinst-swig
CXXSRCS    =
TARGET     = example
INTERFACE  = example.i

check: build
	$(MAKE) -f $(TOP)/Makefile guile_run

build:
	$(MAKE) -f $(TOP)/Makefile CXXSRCS='$(CXXSRCS)' SWIG='$(SWIG)' \
	TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' guile_cpp

static:
	$(MAKE) -f $(TOP)/Makefile CXXSRCS='$(CXXSRCS)' SWIG='$(SWIG)' \
	TARGET='my-guile' INTERFACE='$(INTERFACE)' guile_static_cpp

clean:
	$(MAKE) -f $(TOP)/Makefile TARGET='$(TARGET)' guile_clean
