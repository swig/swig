TOP        = ../..
SWIG       = $(TOP)/../swig
SWIGOPT    = -noruntime
RUNTIMEDIR = $(TOP)/../Runtime/.libs

all::
	$(MAKE) -f $(TOP)/Makefile SWIG='$(SWIG)' SWIGOPT='$(SWIGOPT)' \
	RUNTIMEDIR='$(RUNTIMEDIR)' TARGET='base' INTERFACE='base.i' python_multi_cpp
	$(MAKE) -f $(TOP)/Makefile SWIG='$(SWIG)' SWIGOPT='$(SWIGOPT)' \
	RUNTIMEDIR='$(RUNTIMEDIR)' TARGET='foo' INTERFACE='foo.i' python_multi_cpp
	$(MAKE) -f $(TOP)/Makefile SWIG='$(SWIG)' SWIGOPT='$(SWIGOPT)' \
	RUNTIMEDIR='$(RUNTIMEDIR)' TARGET='bar' INTERFACE='bar.i' python_multi_cpp
	$(MAKE) -f $(TOP)/Makefile SWIG='$(SWIG)' SWIGOPT='$(SWIGOPT)' \
	RUNTIMEDIR='$(RUNTIMEDIR)' TARGET='spam' INTERFACE='spam.i' python_multi_cpp


clean::
	$(MAKE) -f $(TOP)/Makefile python_clean
	@rm -f foo.py bar.py spam.py base.py

check: all
