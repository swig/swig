TOP        = ../..
SWIG       = $(TOP)/../preinst-swig
TARGET     = example
INTERFACE  = example.i
SWIGOPT    =
OBJCSRCS   = runme.m
OBJCFLAGS  = -fconstant-string-class=NSConstantString 

all::
	$(MAKE) -f $(TOP)/Makefile SWIG='$(SWIG)' \
	SWIGOPT='$(SWIGOPT)' TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' objc_cpp
	
clean::
	$(MAKE) -f $(TOP)/Makefile objc_clean

check:: all
	$(MAKE) -f $(TOP)/Makefile OBJCSRCS='$(OBJCSRCS)' OBJCFLAGS='$(OBJCFLAGS)' TARGET='$(TARGET)' objc_run


