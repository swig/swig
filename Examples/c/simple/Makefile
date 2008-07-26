TOP        = ../..
SWIG       = $(TOP)/../preinst-swig -debug-module 4 > tree.txt
SRCS       = example.c
TARGET     = example
INTERFACE  = example.i
RUNME      = runme.c
PROXY      = example_proxy.c
MEMTOOL    = valgrind --leak-check=full

all::
	$(MAKE) -f $(TOP)/Makefile SRCS='$(SRCS)' SWIG='$(SWIG)' \
	TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' c

run:
	$(MAKE) -f $(TOP)/Makefile RUNME='$(RUNME)' PROXY='$(PROXY)' \
	TARGET='$(TARGET)' c_compile
	env LD_LIBRARY_PATH=. ./runme

memchk:
	$(MAKE) -f $(TOP)/Makefile SRCS='$(SRCS)' SWIG='$(SWIG)' \
	TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' CFLAGS='-g' c
	$(MAKE) -f $(TOP)/Makefile RUNME='$(RUNME)' PROXY='$(PROXY)' \
	TARGET='$(TARGET)' CFLAGS='-g' c_compile
	env LD_LIBRARY_PATH=. $(MEMTOOL) ./runme

clean:
	rm -f *.o *.so *.out *.a *.exe *.dll *_wrap* *_proxy* *~ runme

check: all
