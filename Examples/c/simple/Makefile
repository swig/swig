TOP        = ../..
SWIG       = $(TOP)/../preinst-swig -debug-module 4 > tree.txt
SRCS       = example.c
TARGET     = example
INTERFACE  = example.i
MAIN       = test.c

all::
	$(MAKE) -f $(TOP)/Makefile SRCS='$(SRCS)' SWIG='$(SWIG)' \
	TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' MAIN='$(MAIN)' c

clean:
	rm -f *.o *.so *.out *.a *.exe *.dll *_wrap* *_proxy* *~

