TOP        = ../..
SWIG       = $(TOP)/../swig
SRCS       = example.c
TARGET     = example
INTERFACE  = example.i

all::
	$(MAKE) -f $(TOP)/Makefile SRCS='$(SRCS)' SWIG='$(SWIG)' \
	TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' pike

static::
	$(MAKE) -f $(TOP)/Makefile SRCS='$(SRCS)' SWIG='$(SWIG)' \
	TARGET='mypike' INTERFACE='$(INTERFACE)' pike_static

clean::
	-rm -f example_wrap.c example.o example_wrap.o example.so

check: all
