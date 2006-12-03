TOP        = ../..
SWIG       = $(TOP)/../preinst-swig
SRCS       = example.c
TARGET     = example
INTERFACE  = example.i
LIBS       =
SWIGOPT    =

all::
	$(MAKE) -f $(TOP)/Makefile SRCS='$(SRCS)' SWIG='$(SWIG)' \
	SWIGOPT='$(SWIGOPT)' TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' \
	php4

static::
	$(MAKE) -f $(TOP)/Makefile SRCS='$(SRCS)' SWIG='$(SWIG)' \
	SWIGOPT='$(SWIGOPT)' TARGET='myphp4' INTERFACE='$(INTERFACE)' \
	php4_static

clean::
	$(MAKE) -f $(TOP)/Makefile php4_clean
	rm -f $(TARGET).php

check: all
	$(MAKE) -f $(TOP)/Makefile php4_run
