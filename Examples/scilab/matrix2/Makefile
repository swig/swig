TOP	   = ../..
SWIG       = $(TOP)/../preinst-swig
SRCS       = matrixlib.c
TARGET     = matrixlib
INTERFACE  = matrixlib.i

check: build
	$(MAKE) -f $(TOP)/Makefile scilab_run

build:
	$(MAKE) -f $(TOP)/Makefile SRCS='$(SRCS)' SWIG='$(SWIG)' \
	TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' scilab

clean:
	$(MAKE) -f $(TOP)/Makefile scilab_clean
