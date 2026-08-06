TOP        = ../..
SWIGEXE    = $(TOP)/../swig
SWIG_LIB_DIR = $(TOP)/../$(TOP_BUILDDIR_TO_TOP_SRCDIR)Lib
TARGET     = messages
INTERFACE  = messages.i
RUNME      = runme
SWIGOPT    =

check: build
	$(MAKE) -f $(TOP)/Makefile SRCDIR='$(SRCDIR)' RUNME='$(RUNME)' TARGET='$(TARGET)' rust_run

build:
	$(MAKE) -f $(TOP)/Makefile SRCDIR='$(SRCDIR)' \
	SWIG_LIB_DIR='$(SWIG_LIB_DIR)' SWIGEXE='$(SWIGEXE)' \
	SWIGOPT='$(SWIGOPT)' TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' rust_cpp
	$(MAKE) -f $(TOP)/Makefile SRCDIR='$(SRCDIR)' RUNME='$(RUNME)' TARGET='$(TARGET)' RUST_RUNME_CRATE='$(RUNME).rs' rust_compile

clean:
	$(MAKE) -f $(TOP)/Makefile SRCDIR='$(SRCDIR)' RUNME='$(RUNME)' TARGET='$(TARGET)' RUST_RUNME_CRATE='$(RUNME).rs' rust_clean
