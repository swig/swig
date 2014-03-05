TOP        = ../..
SWIG       = $(TOP)/../preinst-swig
CXXSRCS    = class.cxx
TARGET     = example
INTERFACE  = example.i
LIBS       = -lm

check: build
	$(MAKE) -f $(TOP)/Makefile CXXSRCS='$(CXXSRCS)' TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' go_run

build:
	$(MAKE) -f $(TOP)/Makefile CXXSRCS='$(CXXSRCS)' SWIG='$(SWIG)' \
	TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' go_cpp

clean:
	$(MAKE) -f $(TOP)/Makefile INTERFACE='$(INTERFACE)' go_clean
