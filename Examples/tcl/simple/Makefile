TOP        = ../..
SWIG       = $(TOP)/../swig
SRCS       = example.c
TARGET     = my_tclsh
DLTARGET   = example
INTERFACE  = example.i

all::
	$(MAKE) -f $(TOP)/Makefile SRCS='$(SRCS)' SWIG='$(SWIG)' \
	TARGET='$(DLTARGET)' INTERFACE='$(INTERFACE)' tcldl

tcl8::
	$(MAKE) -f $(TOP)/Makefile SRCS='$(SRCS)' SWIG='$(SWIG)' \
	SWIGOPT='-tcl8' TARGET='$(DLTARGET)' INTERFACE='$(INTERFACE)' tcldl

static::
	$(MAKE) -f $(TOP)/Makefile SRCS='$(SRCS)' SWIG='$(SWIG)' \
	TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' tclsh

static8::
	$(MAKE) -f $(TOP)/Makefile SRCS='$(SRCS)' SWIG='$(SWIG)' \
	SWIGOPT='-tcl8' TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' tclsh


clean::
	rm -f *_wrap* *.o my_tclsh *~ .~* core *.so *.sl


