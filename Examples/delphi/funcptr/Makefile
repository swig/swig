TOP        = ../..
SWIG       = $(TOP)/../preinst-swig
SRCS    = example.c
TARGET     = example
INTERFACE  = example.i
SWIGOPT    =
DELPHISRCS = example.pas
DELPHIFLAGS= 

all::	delphi

delphi::
	$(MAKE) -f $(TOP)/Makefile SRCS='$(SRCS)' SWIG='$(SWIG)' \
	SWIGOPT='$(SWIGOPT)' TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' delphi
	$(MAKE) -f $(TOP)/Makefile DELPHISRCS='$(DELPHISRCS)' delphi_compile
	$(MAKE) -f $(TOP)/Makefile DELPHISRCS='runme.dpr' delphi_compile
clean::
	$(MAKE) -f $(TOP)/Makefile delphi_clean

check: all