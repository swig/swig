TOP        = ../..
SWIG       = $(TOP)/../preinst-swig
CXXSRCS    = example.cxx
TARGET     = example
INTERFACE  = example.i
RUNME      = runme.c
PROXY      = example_proxy.c
INCLUDES   = 

all::
	$(MAKE) -f $(TOP)/Makefile CXXSRCS='$(CXXSRCS)' SWIG='$(SWIG)' \
	TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' INCLUDES='$(INCLUDES)' c_cpp
	$(MAKE) -f $(TOP)/Makefile RUNME='$(RUNME)' PROXY='$(PROXY)' \
	TARGET='$(TARGET)' c_compile

run:
	env LD_LIBRARY_PATH=. ./runme

clean:
	rm -f *.o *.out *.so *.a *.dll  *.dylib *.exe *_wrap* *_proxy* *~ runme

check: all
