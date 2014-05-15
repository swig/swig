TOP        = ../..
SWIG       = $(TOP)/../preinst-swig
CXXSRCS    =
TARGET     = my_tclsh
DLTARGET   = example
INTERFACE  = example.i
LIBS       = -lm

check: build
	$(MAKE) -f $(TOP)/Makefile SRCDIR='$(SRCDIR)' tcl_run

build:
	$(MAKE) -f $(TOP)/Makefile SRCDIR='$(SRCDIR)' CXXSRCS='$(CXXSRCS)' SWIG='$(SWIG)' \
	TARGET='$(DLTARGET)' INTERFACE='$(INTERFACE)' tcl_cpp

static:
	$(MAKE) -f $(TOP)/Makefile SRCDIR='$(SRCDIR)' CXXSRCS='$(CXXSRCS)' SWIG='$(SWIG)' \
	TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' tclsh_cpp_static

clean:
	$(MAKE) -f $(TOP)/Makefile SRCDIR='$(SRCDIR)' tcl_clean
