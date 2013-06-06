TOP        = ../..
SWIG       = $(TOP)/../preinst-swig
SRCS       = example.cxx
TARGET     = example
INTERFACE  = example.i

all:
	$(MAKE) -f $(TOP)/Makefile SRCS='$(SRCS)' SWIG='$(SWIG)' \
	TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' scilab_cpp


clean:
	$(MAKE) -f $(TOP)/Makefile scilab_clean
	rm -f *.sce *.so lib*lib.c *_wrap.c *_wrap.cxx

check: all
	$(MAKE) -f $(TOP)/Makefile scilab_run
