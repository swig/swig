TOP        = ../..
SWIG       = $(TOP)/../preinst-swig
CXXSRCS    = $(EXSRCDIR)/example.cxx
TARGET     = swigexample
INTERFACE  = $(EXSRCDIR)/example.i
LIBS       = -lm
SWIGOPT    =

check: build
	$(MAKE) -f $(TOP)/Makefile octave_run

build:
	$(MAKE) -f $(TOP)/Makefile $(SWIGLIB) CXXSRCS='$(CXXSRCS)' SWIG='$(SWIG)' \
	SWIGOPT='$(SWIGOPT)' TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' octave_cpp

clean:
	$(MAKE) -f $(TOP)/Makefile octave_clean
