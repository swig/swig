TOP        = ../..
SWIG       = $(TOP)/../preinst-swig
SRCS       = example.cpp
TARGET     = example
INTERFACE  = example.i

check: build
	$(MAKE) -f $(TOP)/Makefile scilab_run

build:
	$(MAKE) -f $(TOP)/Makefile SRCS='$(SRCS)' SWIG='$(SWIG)' \
	TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' scilab_cpp

clean:
	$(MAKE) -f $(TOP)/Makefile scilab_clean
