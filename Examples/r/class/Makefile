TOP        = ../..
SWIG       = $(TOP)/../preinst-swig
CXXSRCS    = example.cxx
TARGET     = example
INTERFACE  = example.i

all::
	$(MAKE) -f $(TOP)/Makefile CXXSRCS='$(CXXSRCS)' SWIG='$(SWIG)' \
	TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' r_cpp

clean::
	$(MAKE) -f $(TOP)/Makefile INTERFACE='$(INTERFACE)' r_clean

check: all
	R CMD BATCH runme.R
