TOP        = ../..
SWIG       = $(TOP)/../swig
SWIGOPT    = -noruntime
LIBS       = -L. -lruntime

all::
	$(MAKE) -f $(TOP)/Makefile SWIG='$(SWIG)' SWIGOPT='-runtime' \
	LIBPREFIX='lib' TARGET='runtime' INTERFACE='runtime.i' tcl_cpp
	$(MAKE) -f $(TOP)/Makefile SWIG='$(SWIG)' SWIGOPT='$(SWIGOPT)' \
	LIBS='$(LIBS)' TARGET='base' INTERFACE='base.i' tcl_cpp
	$(MAKE) -f $(TOP)/Makefile SWIG='$(SWIG)' SWIGOPT='$(SWIGOPT)' \
	LIBS='$(LIBS)' TARGET='foo' INTERFACE='foo.i' tcl_cpp
	$(MAKE) -f $(TOP)/Makefile SWIG='$(SWIG)' SWIGOPT='$(SWIGOPT)' \
	LIBS='$(LIBS)' TARGET='bar' INTERFACE='bar.i' tcl_cpp
	$(MAKE) -f $(TOP)/Makefile SWIG='$(SWIG)' SWIGOPT='$(SWIGOPT)' \
	LIBS='$(LIBS)' TARGET='spam' INTERFACE='spam.i' tcl_cpp


clean::
	$(MAKE) -f $(TOP)/Makefile tcl_clean

check: all
