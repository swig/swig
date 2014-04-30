TOP        = ../..
SWIG       = $(TOP)/../preinst-swig
SRCS       = example.c
TARGET     = example
INTERFACE  = example.i
SWIGOPT    =

check: build
	$(MAKE) -f $(TOP)/Makefile python_run

build:
	$(MAKE) -f $(TOP)/Makefile SRCS='$(SRCS)' SWIG='$(SWIG)' SWIGOPT='$(SWIGOPT)' \
	TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' python

static:
	$(MAKE) -f $(TOP)/Makefile SRCS='$(SRCS)' SWIG='$(SWIG)' SWIGOPT='$(SWIGOPT)' \
	TARGET='mypython' INTERFACE='$(INTERFACE)' python_static

clean:
	$(MAKE) -f $(TOP)/Makefile TARGET='$(TARGET)' python_clean
