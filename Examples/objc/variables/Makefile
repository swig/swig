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
	$(MAKE) -f $(TOP)/Makefile SRCS='$(SRCS)' SWIG='$(SWIG)' \
	SWIGOPT='$(SWIGOPT)' TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' objc
	$(MAKE) -f $(TOP)/Makefile OBJCSRCS='$(OBJCSRCS)' OBJCFLAGS='(OBJCFLAGS)' objc_compile

clean::
	$(MAKE) -f $(TOP)/Makefile objc_clean

check: all
