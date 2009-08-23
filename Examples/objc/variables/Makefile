TOP        = ../..
SWIG       = $(TOP)/../preinst-swig
CXXSRCS    = example.c
TARGET     = example
INTERFACE  = example.i
SWIGOPT    =
OBJCSRCS= *.m
OBJCPPSRCS= *.mm
OBJCFLAGS= -framework Foundation -L.
OBJCPPFLAGS=

all::	objc

objc::
	$(MAKE) -f $(TOP)/Makefile CXXSRCS='$(CXXSRCS)' OBJCPPSRCS='$(OBJCPPSRCS)' SWIG='$(SWIG)' \
	SWIGOPT='$(SWIGOPT)' TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' objc_cpp
	$(MAKE) -f $(TOP)/Makefile OBJCSRCS='$(OBJCSRCS)' OBJCFLAGS='$(OBJCFLAGS)' TARGET='$(TARGET)' objc_compile

clean::
	$(MAKE) -f $(TOP)/Makefile objc_clean

check: all

