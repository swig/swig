TOP        = ../..
SWIG       = $(TOP)/../preinst-swig
CXXSRCS    = example.cxx
TARGET     = example
INTERFACE  = example.i
LIBS       = -lm

all::
	$(MAKE) -f $(TOP)/Makefile CXXSRCS='$(CXXSRCS)' SWIG='$(SWIG)' \
	TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' go_cpp

clean::
	$(MAKE) -f $(TOP)/Makefile go_clean

check: all
	$(MAKE) -f $(TOP)/Makefile TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' go_run
