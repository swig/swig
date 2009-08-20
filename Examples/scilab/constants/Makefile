TOP        = ../..
SWIG       = $(TOP)/../preinst-swig
SRCS       = example.i
TARGET     = example
INTERFACE  = example.i

all::
	$(MAKE) -f $(TOP)/Makefile SRCS='$(SRCS)' SWIG='$(SWIG)' \
	TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' scilab
	

clean::
	$(MAKE) -f $(TOP)/Makefile scilab_clean
	rm -f *.sce *.so lib*lib.c *_wrap.c

check: all
	$(MAKE) -f $(TOP)/Makefile scilab_run
