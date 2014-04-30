TOP        = ../..
SWIG       = $(TOP)/../preinst-swig
CXXSRCS    = example.cxx
TARGET     = example
INTERFACE  = example.i
SWIGOPT    =
JAVASRCS   = *.java

check: build
	$(MAKE) -f $(TOP)/Makefile java_run

build:
	$(MAKE) -f $(TOP)/Makefile CXXSRCS='$(CXXSRCS)' SWIG='$(SWIG)' \
	SWIGOPT='$(SWIGOPT)' TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' java_cpp
	$(MAKE) -f $(TOP)/Makefile JAVASRCS='$(JAVASRCS)' JAVAFLAGS='$(JAVAFLAGS)' java_compile

clean:
	$(MAKE) -f $(TOP)/Makefile java_clean
