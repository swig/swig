TOP        = ../..
SWIG       = $(TOP)/../preinst-swig
CXXSRCS    = example.cxx
TARGET     = swigexample
INTERFACE  = example.i
LIBS       = -lm
SWIGOPT    =

check: build
	$(MAKE) -f $(TOP)/Makefile SRCDIR='$(SRCDIR)' octave_run

build:
	$(MAKE) -f $(TOP)/Makefile SRCDIR='$(SRCDIR)' $(SWIGLIB) CXXSRCS='$(CXXSRCS)' SWIG='$(SWIG)' \
	SWIGOPT='$(SWIGOPT)' TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' octave_cpp

clean:
	$(MAKE) -f $(TOP)/Makefile SRCDIR='$(SRCDIR)' octave_clean
