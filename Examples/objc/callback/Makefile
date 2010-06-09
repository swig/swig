TOP        = ../..
SWIG       = $(TOP)/../preinst-swig
CXXSRCS    = example.cxx
TARGET     = example
INTERFACE  = example.i
SWIGOPT    =
OBJCXXSRCS = *.mm *.m
OBJCSRCS   = *.m
OBJCFLAGS  = -fconstant-string-class=NSConstantString 

all:: objc

objc::
	$(MAKE) -f $(TOP)/Makefile CXXSRCS='$(CXXSRCS)' OBJCXXSRCS='$(OBJCXXSRCS)' SWIG='$(SWIG)' \
	SWIGOPT='$(SWIGOPT)' TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' objc_cpp
	$(MAKE) -f $(TOP)/Makefile OBJCSRCS='$(OBJCSRCS)' OBJCFLAGS='$(OBJCFLAGS)' TARGET='$(TARGET)' objc_compile

clean::
	$(MAKE) -f $(TOP)/Makefile objc_clean

check: all

