TOP        = ../..
SWIG       = $(TOP)/../preinst-swig
SRCS       = example.c
TARGET     = example
INTERFACE  = example.i
LIBS       =
SWIGOPT    = -noproxy

all::
	$(MAKE) -f $(TOP)/Makefile SRCS='$(SRCS)' SWIG='$(SWIG)' \
	SWIGOPT='$(SWIGOPT)' TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' \
	php

static::
	$(MAKE) -f $(TOP)/Makefile SRCS='$(SRCS)' SWIG='$(SWIG)' \
	SWIGOPT='$(SWIGOPT)' TARGET='myphp' INTERFACE='$(INTERFACE)' \
	php_static

clean::
	$(MAKE) -f $(TOP)/Makefile php_clean
	rm -f $(TARGET).php

check: all
	$(MAKE) -f $(TOP)/Makefile php_run
