TOP        = ../..
SWIG       = $(TOP)/../preinst-swig
SRCS       = example.c
TARGET     = example
INTERFACE  = example.i
MAIN       = main.c

all::
	$(MAKE) -f $(TOP)/Makefile SRCS='$(SRCS)' SWIG='$(SWIG)' \
	TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' MAIN='$(MAIN)' c

clean:
	rm -f *.o *.so *.out *.a *~

