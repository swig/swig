TOP = ../..
SWIG = $(TOP)/../preinst-swig
TARGET = matlab_example
INTERFACE = matlab_example.i
SWIGOPT = -w524

check: build
	$(MAKE) -f $(TOP)/Makefile SRCDIR='$(SRCDIR)' matlab_run

build:
	$(MAKE) -f $(TOP)/Makefile SRCDIR='$(SRCDIR)' SWIG='$(SWIG)' SWIGOPT='$(SWIGOPT)' TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' matlab_cpp

clean:
	$(MAKE) -f $(TOP)/Makefile SRCDIR='$(SRCDIR)' TARGET='$(TARGET)' matlab_clean
