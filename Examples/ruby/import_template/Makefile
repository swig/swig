TOP        = ../..
SWIG       = $(TOP)/../swig
SWIGOPT    = -noruntime
LIBS       = -L. -lruntime
 
all::
	$(MAKE) -f $(TOP)/Makefile SWIG='$(SWIG)' SWIGOPT='-runtime' \
	LIBPREFIX='lib' TARGET='runtime' INTERFACE='runtime.i' ruby_cpp
	$(MAKE) -f $(TOP)/Makefile SWIG='$(SWIG)' SWIGOPT='$(SWIGOPT)' \
	LIBS='$(LIBS)' TARGET='base' INTERFACE='base.i' ruby_cpp
	$(MAKE) -f $(TOP)/Makefile SWIG='$(SWIG)' SWIGOPT='$(SWIGOPT)' \
	LIBS='$(LIBS)' TARGET='foo' INTERFACE='foo.i' ruby_cpp
	$(MAKE) -f $(TOP)/Makefile SWIG='$(SWIG)' SWIGOPT='$(SWIGOPT)' \
	LIBS='$(LIBS)' TARGET='bar' INTERFACE='bar.i' ruby_cpp
	$(MAKE) -f $(TOP)/Makefile SWIG='$(SWIG)' SWIGOPT='$(SWIGOPT)' \
	LIBS='$(LIBS)' TARGET='spam' INTERFACE='spam.i' ruby_cpp

clean::
	$(MAKE) -f $(TOP)/Makefile ruby_clean

check: all
