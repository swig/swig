TOP	   = ../..
SWIG       = $(TOP)/../preinst-swig
SRCS       = matrixlib.c
TARGET     = matrixlib
INTERFACE  = matrixlib.i

all:
	$(MAKE) -f $(TOP)/Makefile SRCS='$(SRCS)' SWIG='$(SWIG)' \
	TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' scilab


clean:
	$(MAKE) -f $(TOP)/Makefile scilab_clean
	rm -f *.sce *.so lib*lib.c *_wrap.c

check: all
	$(MAKE) -f $(TOP)/Makefile scilab_run
