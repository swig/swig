TOP        = ../..
SWIG       = $(TOP)/../preinst-swig -debug-module 4 > tree.txt
CXXSRCS    = example.cxx
TARGET     = example
INTERFACE  = example.i
MAIN       = main.c

all::
	$(MAKE) -f $(TOP)/Makefile CXXSRCS='$(CXXSRCS)' SWIG='$(SWIG)' \
	TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' MAIN='$(MAIN)' c_cpp

clean:
	rm *.o

