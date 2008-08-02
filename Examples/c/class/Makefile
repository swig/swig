TOP        = ../..
SWIG       = $(TOP)/../preinst-swig -debug-module 4 > tree.txt 
CXXSRCS    = example.cxx
TARGET     = example
INTERFACE  = example.i
RUNME      = runme.c
PROXY      = example_proxy.c
MEMTOOL    = valgrind --leak-check=full

all::
	$(MAKE) -f $(TOP)/Makefile CXXSRCS='$(CXXSRCS)' SWIG='$(SWIG)' \
	TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' c_cpp
	$(MAKE) -f $(TOP)/Makefile RUNME='$(RUNME)' PROXY='$(PROXY)' \
	TARGET='$(TARGET)' c_compile

run:
	env LD_LIBRARY_PATH=. ./runme

memchk:
	$(MAKE) -f $(TOP)/Makefile CXXSRCS='$(CXXSRCS)' SWIG='$(SWIG)' \
	TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' CXXFLAGS='-g' c_cpp
	$(MAKE) -f $(TOP)/Makefile RUNME='$(RUNME)' PROXY='$(PROXY)' \
	TARGET='$(TARGET)' CFLAGS='-g' c_compile
	env LD_LIBRARY_PATH=. $(MEMTOOL) ./runme

clean:
	rm -f *.o *.out *.so *.a *.dll *.exe *_wrap* *_proxy* *~ runme

check: all
