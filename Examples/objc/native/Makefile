TOP        = ../..
SWIG       = $(TOP)/../preinst-swig
TARGET     = example
INTERFACE  = example.i
SWIGOPT    =
SRCS       = 
OBJCXXSRCS = exampleWrapper.mm exampleProxy.m
OBJCSRCS   = runme.m
OBJCFLAGS  = -fconstant-string-class=NSConstantString 

all:: objc

objc::
	$(MAKE) -f $(TOP)/Makefile SRCS='$(SRCS)' OBJCXXSRCS='$(OBJCXXSRCS)' SWIG='$(SWIG)' \
	SWIGOPT='$(SWIGOPT)' TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' objc
	$(MAKE) -f $(TOP)/Makefile OBJCSRCS='$(OBJCSRCS)' OBJCFLAGS='$(OBJCFLAGS)' TARGET='$(TARGET)' objc_compile

clean::
	$(MAKE) -f $(TOP)/Makefile objc_clean

check: all

