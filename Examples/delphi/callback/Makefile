TOP        = ../..
SWIGEXE    = $(TOP)/../swig
SWIG_LIB_DIR = $(TOP)/../$(TOP_BUILDDIR_TO_TOP_SRCDIR)Lib
CXXSRCS    = example.cxx
TARGET     = example
INTERFACE  = example.i
SWIGOPT    = 
DELPHISRCS = example.pas
DELPHIFLAGS= 

check: build
	$(MAKE) -f $(TOP)/Makefile SRCDIR='$(SRCDIR)' delphi_run

build:
	$(MAKE) -f $(TOP)/Makefile SRCDIR='$(SRCDIR)' SRCS='$(SRCS)' \
	SWIG_LIB_DIR='$(SWIG_LIB_DIR)' SWIGEXE='$(SWIGEXE)' \
	SWIGOPT='$(SWIGOPT)' TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' delphi_cpp
	$(MAKE) -f $(TOP)/Makefile DELPHISRCS='$(DELPHISRCS)' delphi_compile
	$(MAKE) -f $(TOP)/Makefile DELPHISRCS='runme.dpr' delphi_compile

clean:
	$(MAKE) -f $(TOP)/Makefile SRCDIR='$(SRCDIR)' delphi_clean
