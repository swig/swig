TOP        = ../../..
SWIG       = $(TOP)/../preinst-swig
SRCS       =
TARGET     = example
INTERFACE  = example.i

all: check

loader.sce:
	$(MAKE) -f $(TOP)/Makefile SRCS='$(SRCS)' SWIG='$(SWIG)' \
	TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' scilab_cpp

clean:
	$(MAKE) -f $(TOP)/Makefile scilab_clean

check: loader.sce
	$(MAKE) -f $(TOP)/Makefile scilab_run

debug: loader.sce
	$(MAKE) -f $(TOP)/Makefile scilab_debug
