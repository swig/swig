TOP        = ../..
SWIG       = $(TOP)/../preinst-swig
SRCS       = example.c
TARGET     = example
INTERFACE  = example.i
LIBS       =

check: build
	$(MAKE) -f $(TOP)/Makefile lua_run

build:
	$(MAKE) -f $(TOP)/Makefile SRCS='$(SRCS)' SWIG='$(SWIG)' \
	TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' lua

static:
	$(MAKE) -f $(TOP)/Makefile SRCS='$(SRCS)' SWIG='$(SWIG)' \
	TARGET='mylua' INTERFACE='$(INTERFACE)' lua_static

clean:
	$(MAKE) -f $(TOP)/Makefile lua_clean
