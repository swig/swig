TOP        = ../..
SWIG       = $(TOP)/../swig
SWIGOPT    = -noruntime
LIBS       = -L. -lruntime

all::
	$(MAKE) -f $(TOP)/Makefile SWIG='$(SWIG)' SWIGOPT='-runtime' \
	LIBPREFIX='lib' TARGET='runtime' INTERFACE='runtime.i' perl5_cpp
	$(MAKE) -f $(TOP)/Makefile SWIG='$(SWIG)' SWIGOPT='$(SWIGOPT)' \
	LIBS='$(LIBS)' TARGET='baseclass' INTERFACE='base.i' perl5_cpp
	$(MAKE) -f $(TOP)/Makefile SWIG='$(SWIG)' SWIGOPT='$(SWIGOPT)' \
	LIBS='$(LIBS)' TARGET='foo' INTERFACE='foo.i' perl5_cpp
	$(MAKE) -f $(TOP)/Makefile SWIG='$(SWIG)' SWIGOPT='$(SWIGOPT)' \
	LIBS='$(LIBS)' TARGET='bar' INTERFACE='bar.i' perl5_cpp
	$(MAKE) -f $(TOP)/Makefile SWIG='$(SWIG)' SWIGOPT='$(SWIGOPT)' \
	LIBS='$(LIBS)' TARGET='spam' INTERFACE='spam.i' perl5_cpp


clean::
	$(MAKE) -f $(TOP)/Makefile perl5_clean

check: all
