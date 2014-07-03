TOP        = ../..
SWIG       = $(TOP)/../preinst-swig
SRCS       =
TARGET     = example
INTERFACE  = example.i

check: build
	$(MAKE) -f $(TOP)/Makefile SRCDIR='$(SRCDIR)' scilab_run

build:
	$(MAKE) -f $(TOP)/Makefile SRCS='$(SRCS)' SRCDIR='$(SRCDIR)' SWIG='$(SWIG)' \
	TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' scilab

clean:
	$(MAKE) -f $(TOP)/Makefile SRCDIR='$(SRCDIR)' scilab_clean
