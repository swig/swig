TOP        = ../..
SWIG       = $(TOP)/../preinst-swig -debug-module 4 > tree.txt
CXXSRCS    = example.cxx
TARGET     = example
INTERFACE  = example.i
RUNME      = runme.c
PROXY      = example_proxy.c

all::
	$(MAKE) -f $(TOP)/Makefile CXXSRCS='$(CXXSRCS)' SWIG='$(SWIG)' \
	TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' c_cpp

run:
	$(MAKE) -f $(TOP)/Makefile RUNME='$(RUNME)' PROXY='$(PROXY)' \
	TARGET='$(TARGET)' c_compile
	env LD_LIBRARY_PATH=. ./runme

clean:
	rm -f *.o *.out *.so *.a *.dll *.exe *_wrap* *_proxy* *~

check: all
