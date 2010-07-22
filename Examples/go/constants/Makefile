TOP        = ../..
SWIG       = $(TOP)/../preinst-swig
CXXSRCS    = 
TARGET     = example
INTERFACE  = example.i
SWIGOPT    =

all::
	$(MAKE) -f $(TOP)/Makefile CXXSRCS='$(CXXSRCS)' SWIG='$(SWIG)' \
	SWIGOPT='$(SWIGOPT)' TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' go

clean::
	$(MAKE) -f $(TOP)/Makefile go_clean

check: all
	$(MAKE) -f $(TOP)/Makefile TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' go_run
