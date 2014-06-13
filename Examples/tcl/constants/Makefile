TOP        = ../..
SWIG       = $(TOP)/../preinst-swig
SRCS       =
TARGET     = my_tclsh
DLTARGET   = example
INTERFACE  = example.i

check: build
	$(MAKE) -f $(TOP)/Makefile SRCDIR='$(SRCDIR)' tcl_run

build:
	$(MAKE) -f $(TOP)/Makefile SRCDIR='$(SRCDIR)' SRCS='$(SRCS)' SWIG='$(SWIG)' \
	TARGET='$(DLTARGET)' INTERFACE='$(INTERFACE)' tcl

static:
	$(MAKE) -f $(TOP)/Makefile SRCDIR='$(SRCDIR)' SRCS='$(SRCS)' SWIG='$(SWIG)' \
	TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' tclsh

clean:
	$(MAKE) -f $(TOP)/Makefile SRCDIR='$(SRCDIR)' tcl_clean
