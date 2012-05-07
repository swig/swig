TOP        = ../..
SWIG       = $(TOP)/../preinst-swig
SRCS       = example.c
TARGET     = example
INTERFACE  = example.i
RUNME      = runme.c
PROXY      = example_proxy.c

all::
	$(MAKE) -f $(TOP)/Makefile SRCS='$(SRCS)' SWIG='$(SWIG)' \
	TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' c
	$(MAKE) -f $(TOP)/Makefile RUNME='$(RUNME)' PROXY='$(PROXY)' \
	TARGET='$(TARGET)' c_compile

run:
	env LD_LIBRARY_PATH=. ./runme

clean:
	rm -f *.o *.so *.out *.a *.exe *.dll  *.dylib *_wrap* *_proxy* *~ runme

check: all
