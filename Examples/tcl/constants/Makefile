TOP        = ../..
SWIG       = $(TOP)/../preinst-swig
SRCS       =
TARGET     = my_tclsh
DLTARGET   = example
INTERFACE  = example.i

all::
	$(MAKE) -f $(TOP)/Makefile SRCS='$(SRCS)' SWIG='$(SWIG)' \
	TARGET='$(DLTARGET)' INTERFACE='$(INTERFACE)' tcl

static::
	$(MAKE) -f $(TOP)/Makefile SRCS='$(SRCS)' SWIG='$(SWIG)' \
	TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' tclsh

clean::
	$(MAKE) -f $(TOP)/Makefile tcl_clean

check: all
