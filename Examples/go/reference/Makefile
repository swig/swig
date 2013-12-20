TOP        = ../..
SWIG       = $(TOP)/../preinst-swig
CXXSRCS    = reference.cxx
TARGET     = example
INTERFACE  = example.i
SWIGOPT    =

check: build
	$(MAKE) -f $(TOP)/Makefile CXXSRCS='$(CXXSRCS)' TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' go_run

build:
	$(MAKE) -f $(TOP)/Makefile CXXSRCS='$(CXXSRCS)' SWIG='$(SWIG)' \
	SWIGOPT='$(SWIGOPT)' TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' go_cpp

clean:
	$(MAKE) -f $(TOP)/Makefile INTERFACE='$(INTERFACE)' go_clean
