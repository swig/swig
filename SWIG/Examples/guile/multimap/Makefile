TOP        = ../..
SWIG       = $(TOP)/../swig
SRCS       = example.c
TARGET     = example
INTERFACE  = example.i

all::
	$(MAKE) -f $(TOP)/Makefile SRCS='$(SRCS)' SWIG='$(SWIG)' \
	TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' guile

static::
	$(MAKE) -f $(TOP)/Makefile SRCS='$(SRCS)' SWIG='$(SWIG)' \
	TARGET='my-guile' INTERFACE='$(INTERFACE)' guile_static

clean::
	rm -f *_wrap* *.o *~ *.so my-guile .~* core

check: all
