TOP        = ../..
SWIG       = $(TOP)/../preinst-swig
SRCS    = example.c
TARGET     = example
INTERFACE  = example.i
SWIGOPT    =
OBJCSRCS   = runme.m
OBJCFLAGS  = -fconstant-string-class=NSConstantString 

all::
	$(MAKE) -f $(TOP)/Makefile SRCS='$(SRCS)' SWIG='$(SWIG)' \
	SWIGOPT='$(SWIGOPT)' TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' objc
	
clean::
	$(MAKE) -f $(TOP)/Makefile objc_clean

check:: all
	$(MAKE) -f $(TOP)/Makefile OBJCSRCS='$(OBJCSRCS)' OBJCFLAGS='$(OBJCFLAGS)' TARGET='$(TARGET)' objc_run
