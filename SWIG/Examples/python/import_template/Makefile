TOP        = ../..
SWIG       = $(TOP)/../swig
SWIGOPT    = -c -shadow 
#If your system requires linking with the runtime libraries then set the directory location here
RUNTIMEDIR = 

all::
	$(MAKE) -f $(TOP)/Makefile SWIG='$(SWIG)' SWIGOPT='$(SWIGOPT)' \
	RUNTIMEDIR='$(RUNTIMEDIR)' TARGET='basec' INTERFACE='base.i' python_multi_cpp
	$(MAKE) -f $(TOP)/Makefile SWIG='$(SWIG)' SWIGOPT='$(SWIGOPT)' \
	RUNTIMEDIR='$(RUNTIMEDIR)' TARGET='fooc' INTERFACE='foo.i' python_multi_cpp
	$(MAKE) -f $(TOP)/Makefile SWIG='$(SWIG)' SWIGOPT='$(SWIGOPT)' \
	RUNTIMEDIR='$(RUNTIMEDIR)' TARGET='barc' INTERFACE='bar.i' python_multi_cpp
	$(MAKE) -f $(TOP)/Makefile SWIG='$(SWIG)' SWIGOPT='$(SWIGOPT)' \
	RUNTIMEDIR='$(RUNTIMEDIR)' TARGET='spamc' INTERFACE='spam.i' python_multi_cpp


clean::
	$(MAKE) -f $(TOP)/Makefile python_clean
	@rm -f foo.py bar.py spam.py base.py

check: all
